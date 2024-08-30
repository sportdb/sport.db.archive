################################################
# Datafile for England (and Wales)
#
#  use (inside the england/ folder)
#    $ sportdb build


inline do
  Country.parse 'eng', 'England',  'ENG',  '130_395 km²',  '53_013_000'
  Country.parse 'wal', 'Wales',    'WAL',  '20_779 km²',   '3_064_000'
end

football 'england'

# note: for now use only 2019-20.txt setup (not the default all.txt)
# football 'england', setup: '2019-20'
