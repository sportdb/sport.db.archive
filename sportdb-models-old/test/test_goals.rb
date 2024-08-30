# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_goals.rb


require 'helper'

class TestGoals < MiniTest::Test

  def setup
    WorldDb.delete!
    SportDb.delete!
    ## SportDb.read_builtin

    add_countries
  end

  def add_countries
    countries = [
      ['cd', 'Congo DR',       'COD' ],
      ['kr', 'South Korea',    'KOR' ],
      ['au', 'Australia',      'AUS' ],

      ['ar', 'Argentina',      'ARG' ],
      ['br', 'Brazil',         'BRA' ],
      ['bo', 'Bolivia',        'BOL' ],
      ['cl', 'Chile',          'CHI' ],
      ['co', 'Colombia',       'COL' ],
      ['uy', 'Uruguay',        'URU' ],
      ['pe', 'Peru',           'PER' ],
      ['py', 'Paraguay',       'PAR' ],

      ['mx', 'Mexico',         'MEX' ],
      ['us', 'United States',  'USA' ],
      ['ht', 'Haiti',          'HAI' ],

      ['at', 'Austria',        'AUT' ],
      ['be', 'Belgium',        'BEL' ],
      ['fr', 'France',         'FRA' ],
      ['rs', 'Serbia',         'SRB' ],
      ['ro', 'Romania',        'ROU' ],
      ['bg', 'Bulgaria',       'BUL' ],
      ['cz', 'Czech Republic', 'CZE' ],
      ['en', 'England',        'ENG' ],
      ['de', 'Germany',        'GER' ],
      ['hu', 'Hungary',        'HUN' ],
      ['it', 'Italy',          'ITA' ],
      ['ru', 'Russia',         'RUS' ],
      ['es', 'Spain',          'ESP' ],
      ['ch', 'Switzerland',    'SUI' ],
      ['sc', 'Scotland',       'SCO' ],
      ['tr', 'Turkey',         'TUR' ],
      ['nl', 'Netherlands',    'NED' ],
      ['pl', 'Poland',         'POL' ],
      ['se', 'Sweden',         'SWE' ],
    ]

    countries.each do |country|
      key   = country[0]
      name  = country[1]
      code  = country[2]
      Country.create!( key: key, name: name, code: code, pop: 1, area: 1)
    end
  end


  def test_world_cup_1930
    teamreader = TestTeamReader.from_file( 'world-cup/teams_1930' )
    teamreader.read()

    assert_equal  13, Team.count

    seasonreader = TestSeasonReader.from_file( 'world-cup/seasons_1930' )
    seasonreader.read()

    assert_equal 1, Season.count

    y = Season.find_by_key!( '1930' )
    assert_equal '1930', y.title


    leaguereader = TestLeagueReader.from_file( 'world-cup/leagues' )
    leaguereader.read()

    assert_equal 1, League.count

    l = League.find_by_key!( 'world' )
    assert_equal 'World Cup', l.title


    gamereader = TestGameReader.from_file( 'world-cup/1930/cup_goals' )
    gamereader.read()

    assert_equal 1, Event.count

    w = Event.find_by_key!( 'world.1930' )

    assert_equal  13, w.teams.count
    ## assert_equal  18, w.games.count
    ## assert_equal  12, w.rounds.count

  end  # method test_world_cup_1930


end # class TestGoals
