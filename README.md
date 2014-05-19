# sport.db.api.starter - sportdb web service starter sample

Let's build your own HTTP JSON API using the
`football.db`, `worldcup.db`, `ski.db`, `formulal1.db`, etc.


## Getting Started

Step 1: Install all libraries (Ruby gems) using bundler. Issue

    $ bundle install

Step 2: Copy a `football.db` into your app folder

Step 3: Startup the web service (HTTP JSON API) using rack. Issue

    $ rackup

That's it. Open your browser and try some services
running on localhost on port 9292:

List all World Cup 2014 teams:

- `http://localhost:9292/event/world.2014/teams`

List all World Cup 2014 rounds:

- `http://localhost:9292/event/world.2014/rounds`

List World Cup 2014 round 1:

- `http://localhost:9292/event/world.2014/round/1`

and so on. Now change the `server.rb` script to fit your needs. Be bold. Enjoy.


## License

The `sportdb.db.api.starter` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?

Send them along to the
[Open Sports & Friends Forum/Mailing List](http://groups.google.com/group/opensport).
Thanks!
