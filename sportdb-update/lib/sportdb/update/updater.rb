# encoding: utf-8

###
# note: Updates lives/resides in "regular" SportDb namespace
#  do NOT use nested SportDb::Update namespace


module SportDb

  class Updater

    include LogUtils::Logging

    ######
    # NB: make models available in sportdb module by default with namespace
    #  e.g. lets you use Team instead of Model::Team
    include Models


    def map_event_to_dlurl( event )

      league_key = event.league.key
      season_key = event.season.key

      repo_path, folder_path = map_key_to_repo_n_folder_path( league_key )
      
      return nil if repo_path.nil?   # no match/mapping found; cancel download

      season_path = season_key.gsub( '/', '_')  # convert 2013/14 to 2013_14

      #####
      # quick hack!!!!
      # - find something better e.g. more generic/easy to configure etc.
      if league_key == 'world'   # world cup repo mappings include host country e.g. 2014--brazil etc.
        season_path = '2006--germany'       if season_path == '2006'
        season_path = '2010--south-africa'  if season_path == '2010'
        season_path = '2014--brazil'        if season_path == '2014'
      end

      ###
      # e.g. https://raw.github.com/openfootball/at-austria/master/2013_14

      dlurl = "https://raw.github.com/openfootball/#{repo_path}/master"
      dlurl << "/#{folder_path}" if folder_path.present?
      dlurl << "/#{season_path}"
      dlurl
    end


    def map_key_to_repo_n_folder_path( key )

      ### allow * for regex match w/ .+
      map = [
        [ 'at',         'at-austria'  ],
        [ 'at.*',       'at-austria'  ],
        [ 'de',         'de-deutschland' ],
        [ 'de.*',       'de-deutschland'  ],
        [ 'en',         'en-england' ],
        [ 'es',         'es-espana' ],
        [ 'it',         'it-italy' ],
        [ 'be',         'europe', 'be-belgium' ], # NB: europe/be-belgium
        [ 'ro',         'europe', 'ro-romania' ],
        [ 'cl',         'europe-champions-league' ],
        [ 'el',         'europe-champions-league' ],
        [ 'br',         'br-brazil' ],
        [ 'mx',         'mx-mexico' ],  # todo: add mx.* for clausura etc ??
        [ 'euro',       'euro-cup'  ],
        [ 'world',      'world-cup' ],
        [ 'world.*',    'world-cup' ]]

      map.each do |entry|
         pattern = entry[0]
         path    = [ entry[1], entry[2] ]  # repo n folder path
         
         if pattern.index( '*' ).nil?  # match just plain string (no wildcard *)
           return path if key == pattern
         else
           # assume regex match
           regex = pattern.gsub( '.', '\.' ).gsub( '*', '.+' )
           return path if key =~ /#{regex}/
         end
      end
      nil  # return nil; no match found
    end

    def update_event( event )
      logger.info "update event >>#{event.title}<< (#{event.league.key}+#{event.season.key})"

      dlbase = map_event_to_dlurl( event )
      if dlbase.nil?
        logger.warn "  [Updater] skip download; no download source mapping found for >#{event.key}<"
        return  # cancel download; no mapping found
      end

      puts "  using dlbase >>#{dlbase}<<"

      if event.sources.nil?
        logger.warn "  [Updater] skip download; no download event source configured/found for >#{event.key}<"
        return
      end

      sources = event.sources.gsub(' ','').split(',')   # NB: remove all blanks (leading,trailing,inside)


      text_ary = []   # array of fixtures (text)

      ## collect all fixtures (text)
      sources.each_with_index do |source,i|
        dlurl = "#{dlbase}/#{source}.txt"
        logger.info "   downloading source (#{i+1}/#{sources.length}) >>#{dlurl}<< ..."     # todo/check: use size for ary or length - does it matter?

        # download fixtures into string
        text = Fetcher.read( dlurl )

        logger.debug "text.encoding.name (before): #{text.encoding.name}"
        
        ###
        # NB: Net::HTTP will NOT set encoding UTF-8 etc.
        #  will mostly be ASCII
        #  - try to change encoding to UTF-8 ourselves

        #####
        # NB:  ASCII-8BIT == BINARY == Encoding Unknown; Raw Bytes Here

        ## NB:
        #  for now "hardcoded" to utf8 - what else can we do?
        #  - note: force_encoding will NOT change the chars only change the assumed encoding w/o translation
        text = text.force_encoding( Encoding::UTF_8 )
        logger.debug "text.encoding.name (after): #{text.encoding.name}"

        text_ary << text
      end

      ## note: need to pass in all fixtures at once (e.g as array) for @last_pos calc etc to work
      ##         if multipe "files"/strings are used
      unless text_ary.empty?
        puts "   importing/reading source..."
        # passing dummy include_path (not needed for reading from string)
        # fix: use/add proper api for reading from string e.g. read and read_file ?? etc.
        reader= GameReader.new( '/tmp' )
        ### fix: allow to pass in event (to avoid lookup)
        reader.read_fixtures_from_string( event.key, text_ary )
      end
    end


    def run
      # for now update all events (fixtures only) - not *.yml

      Event.all.each do |event|
        update_event( event )
      end

    end
    
  end # class Updater
  
end # module SportDb