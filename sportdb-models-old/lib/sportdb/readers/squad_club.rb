# encoding: UTF-8


module SportDb

###
#  todo/fix: use one squad reader for
#    national teams and clubs? possible? why? why not?


class ClubSquadReader

  include LogUtils::Logging

## make models available by default with namespace
#  e.g. lets you use Usage instead of Model::Usage
  include Models

## value helpers e.g. is_year?, is_taglist? etc.
  include TextUtils::ValueHelper

  include FixtureHelpers


  def self.from_zip( zip_file, entry_path, more_attribs={} )
    ## get text content from zip
    entry = zip_file.find_entry( entry_path )

    text = entry.get_input_stream().read()
    text = text.force_encoding( Encoding::UTF_8 )

    self.from_string( text, more_attribs )
  end

  def self.from_file( path, more_attribs={} )
    ## note: assume/enfore utf-8 encoding (with or without BOM - byte order mark)
    ## - see textutils/utils.rb
    text = File.read_utf8( path )
    self.from_string( text, more_attribs )
  end

  def self.from_string( text, more_attribs={} )
    ClubSquadReader.new( text, more_attribs )
  end  


  def initialize( text, more_attribs={} )
    ## todo/fix: how to add opts={} ???
    @text = text
    @more_attribs = more_attribs
  end



  def read
    ## note:
    #    event_id and team_id required!!

    # event
    @event = Event.find( @more_attribs[:event_id] )
    pp @event

    ## note: use @team - share/use in worker method
    @team = Team.find( @more_attribs[:team_id] )
    pp @team

    ### SportDb.lang.lang = LangChecker.new.analyze( name, include_path )

    ## mapping tables for persons per country (indexed by country code); reset
    @country_persons_cache = {}

    reader = LineReader.from_string( @text )

    read_worker( reader )

    ## Prop.create_from_fixture!( name, path )  
  end


  def read_worker( reader )
    ##
    ## fix: use num (optional) for offical jersey number
    #  use pos for internal use only (ordering)

    pos_counter = 999000   # pos counter for undefined players w/o pos

    reader.each_line do |line|
      logger.debug "  line: >#{line}<"

      cut_off_end_of_line_comment!( line )

      pos = find_leading_num!( line )

      if pos.nil?
        pos_counter+=1       ## e.g. 999001,999002 etc.
        pos = pos_counter
      end

      nationality = find_nationality!( line )  # e.g. ARG,AUT,USA,MEX etc. (three-letter country code)

      if nationality.nil?
        ## note: use/assume team's nationality is player's nationality
        nationality = @team.country.code
      end

      ## note: for now allow lines w/ missing country records in db (used in unit tests)
      country = Country.find_by_code( nationality )
      if country.nil?
        logger.warn "*** no country found for code >#{nationality}< in line: >#{line}<"
        person_key = nil   ## no country, no mapping table - canNOT map person
      else
        ## try mapping person using country table
        ##   cache mapping table by country code

        country_persons = @country_persons_cache[ country.code ]
        if country_persons.nil?
          logger.info "  persons count for country (#{country.code}): #{country.persons.count}"
          country_persons = TextUtils.build_title_table_for( country.persons )
          @country_persons_cache[ country.code ] = country_persons   # cache mapping table
        end

         map_person!( line, country_persons )
         person_key = find_person!( line )
      end


      logger.debug "  line2: >#{line}<"

      if person_key.nil?
        ## no person match found; try auto-add person
        logger.info "  !! no player match found; try auto-create player"

        buf = line.clone
        # remove (single match) if line starts w/ - (allow spaces)  e.g. | - or |-  note: must start line e.g. anchor ^ used
        buf = buf.sub( /^[ ]*-[ ]*/, '' )    # remove leading dash -  for jersey number n/a
        buf = buf.gsub( /\[[^\]]+\]/, '' )         # remove [POS] or similar
        buf = buf.sub( '(c)', '' )    # remove captain marker
        buf = buf.sub( '(vc)', '' )   # remove vice-captain marker
        ### note: uses sub; assumes one pos marker per line
        buf = buf.sub( /\b(GK|DF|MF|FW)\b/, '' )   # remove position marker
        # since year/date  e.g. 2011-  assume one per line
        #   note: use (?= |$) lookahead e.g. must be followed by space or end-of-line
        buf = buf.sub( /\b\d{4}-?(?= |$)/, '' )
        buf = buf.strip   # remove leading and trailing spaces

        ## assume what's left is player name
        logger.info "   player_name >#{buf}<"

        ## fix: add auto flag (for auto-created persons/players)
        ## fix: move title_to_key logic to person model etc.
        person_attribs = {
               key:   TextUtils.title_to_key( buf ),
               title: buf
        }

        # note: add country from team or nationality marker
        if country
          person_attribs[ :country_id     ] = country.id
          person_attribs[ :nationality_id ] = country.id
        end

        logger.info "   using attribs: #{person_attribs.inspect}"

        person = Person.create!( person_attribs )
      else
        person = Person.find_by_key( person_key )

        if person.nil?
          logger.error " !!!!!! no mapping found for player in line >#{line}< for team #{@team.code} - #{@team.title}"
          next   ## skip further processing of line; can NOT save w/o person; continue w/ next record
        end
      end


      ### check if roster record exists
      roster = Roster.find_by_event_id_and_team_id_and_person_id( @event.id, @team.id, person.id )

      if roster.present?
        logger.debug "update Roster #{roster.id}:"
      else
        logger.debug "create Roster:"
        roster = Roster.new
      end

      roster_attribs = {
        pos:       pos,
        person_id: person.id,
        team_id:   @team.id,
        event_id:  @event.id   # NB: reuse/fallthrough from races - make sure load_races goes first (to setup event)
      }

      logger.debug roster_attribs.to_json

      roster.update_attributes!( roster_attribs )
    end # lines.each

  end # method read_worker


end # class ClubSquadReader
end # module SportDb
