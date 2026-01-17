
get '/rounds/:q' do
  q = params[ 'q' ]

  #################
  # todo/check:
  #   what to do for special case with postponed games/matches??
  #    if match postponed round end_at date also gets moved back!
  #     use a different end_at date for original end_at e.g add a new field? why? why not?
  #  -- if round out of original scope mark as postponed (e.g. spielrunde 5 - nachtrag!)

  rounds = []

  if q =~ /(\d{1,2})\.(\d{1,2})\.(\d{4})/
    d = Date.new( $3.to_i, $2.to_i, $1.to_i )
  elsif q =~ /(\d{4})\.(\d{1,2})\.(\d{1,2})/
    d = Date.new( $1.to_i, $2.to_i, $3.to_i )
  else
    d = Date.today   # no match - assume today's/current date
  end

  current_rounds = Round.where( 'start_date <= ? and end_date >= ?', d, d )
  current_rounds.each do |r|
    rounds << { pos:  r.pos,
                name: r.name,
                start_date: r.start_date ? r.start_date.strftime('%Y/%m/%d') : '?',
                end_date:   r.end_date   ? r.end_date.strftime('%Y/%m/%d')   : '?',
                event: { key:   r.event.key,
                         name:  r.event.name }}
  end

  data = { rounds: rounds }
  data
end


get '/event/:key/teams' do
  key = params['key']

  # note: change en.2012_13 to en.2012/13
  event = Event.find_by!( key: key.tr('_', '/') )

  teams = []
  event.teams.each do |t|
    teams << { key: t.key, name: t.name, code: t.code }
  end

  data = { event: { key:   event.key,
                    name:  event.name },
           teams: teams }
  data
end


get '/event/:key/rounds' do
  key = params['key']

  # note: change en.2012_13 to en.2012/13
  event = Event.find_by!( key: key.tr('_', '/') )

  rounds = []
  event.rounds.each do |r|
    rounds << { pos: r.pos,
                name: r.name,
                start_date: r.start_date ? r.start_date.strftime('%Y/%m/%d') : '?',
                end_date:   r.end_date   ? r.end_date.strftime('%Y/%m/%d')   : '?'}
  end

  data = { event: { key: event.key,
                    name: event.name },
           rounds: rounds }
  data
end


get '/event/:key/round/:pos' do
  key = params[ 'key' ]
  pos = params[ 'pos' ]

  # note: change en.2012_13 to en.2012/13
  event = Event.find_by!( key: key.tr('_', '/') )

  if pos =~ /\d+/
    round = Round.find_by!( event_id: event.id,
                            pos:      pos )
  else  # assume last from today's date (use last/today/etc. - must be non-numeric key)
    d = Date.today
    round = Round.where( event_id: event.id ).where( 'start_date <= ?', d ).order( 'pos' ).last
    if round.nil?   # assume all rounds in the future; display first upcoming one
      round = Round.where( event_id: event.id ).order('pos').first
    end
  end

  matches = []
  round.matches.each do |m|
    matches << { team1_key: m.team1.key, team1_name: m.team1.name, team1_code: m.team1.code,
               team2_key: m.team2.key, team2_name: m.team2.name, team2_code: m.team2.code,
               date: m.date ? m.date.strftime('%Y/%m/%d') : '?',
               score1:   m.score1,   score2:   m.score2,
               score1ot: m.score1ot, score2ot: m.score2ot,
               score1p:  m.score1p,  score2p:  m.score2p
             }
  end

  data = { event: { key: event.key, name: event.name },
           round: { pos: round.pos, name: round.name,
                    start_date: round.start_date ? round.start_date.strftime('%Y/%m/%d') : '?',
                    end_date:   round.end_date   ? round.end_date.strftime('%Y/%m/%d')   : '?'
                  },
           matches: matches }

  data
end

