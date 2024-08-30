# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_squad_club_reader.rb
#  or better
#     rake -I ./lib test


require 'helper'

class TestSquadClubReaderXX < MiniTest::Test  # note: TestSquadClubReader alreay defined, thus, add xx

  def setup
    WorldDb.delete!
    SportDb.delete!
    PersonDb.delete!

    add_bl
  end

  def add_bl
    SportDb.read_builtin   # add 2013/14 season

    at = Country.create!( key: 'at', name: 'Austria', code: 'AUT', pop: 1, area: 1)
    
    teamreader = TestTeamReader.from_file( 'at-austria/teams', country_id: at.id )
    teamreader.read()

    leaguereader = TestLeagueReader.from_file( 'at-austria/leagues', country_id: at.id )
    leaguereader.read()

    ## check/fix: is country_id more_attribs needed? why? why not?
    gamereader = TestGameReader.from_file( 'at-austria/2013_14/bl', country_id: at.id )
    gamereader.read()

    bl = Event.find_by_key!( 'at.2013/14' )

    assert_equal  10, bl.teams.count
    assert_equal  36, bl.rounds.count
    assert_equal 180, bl.games.count  # 36x5 = 180
 
    ## add players
    ## -- read persons
    ## personreader = PersonReader.new( SportDb.test_data_path )
    ## personreader.read( 'players/europe/at-austria/players', country_id: at.id ) 

    ## assert_equal 30, Person.count
  end


  def test_austria
    austria = Team.find_by_key!( 'austria' )

    event = Event.find_by_key!( 'at.2013/14' )

    reader = TestClubSquadReader.from_file( 'at-austria/2013_14/squads/austria', team_id: austria.id, event_id: event.id )
    reader.read()

    assert_equal 28, Roster.count
  end  # method test_br


  def test_salzburg
    salzburg = Team.find_by_key!( 'salzburg' )

    event = Event.find_by_key!( 'at.2013/14' )

    reader = TestClubSquadReader.from_file( 'at-austria/2013_14/squads/salzburg', team_id: salzburg.id, event_id: event.id )
    reader.read()

    assert_equal 27, Roster.count
  end  # method test_salzburg


end # class TestSquadClubReader
