# sport.db.starter (Ruby Edition)

The sportdb web service starter sample let's build your own HTTP JSON API using the
`football.db`, `worldcup.db`, `ski.db`, `formulal1.db`, etc.
 

## Getting Started

Step 1: Install all libraries (Ruby gems) using bundler. Type:

    $ bundle install

Step 2: Copy a `football.db` into your app folder.

Step 3: Startup the web service (HTTP JSON API). Type:

    $ ruby server.rb

That's it. Open your browser and try some services
running on localhost on port 9292. Example:


List all services (endpoints):

- `http://localhost:9292`

List all events:

- `http://localhost:9292/events`

List all World Cup 2014 teams:

- `http://localhost:9292/event/world.2014/teams`

List all World Cup 2014 rounds:

- `http://localhost:9292/event/world.2014/rounds`

List World Cup 2014 round 1:

- `http://localhost:9292/event/world.2014/round/1`

And so on. Now change the `app.rb` script to fit your needs. Be bold. Enjoy.


## License

The `sportdb.db.starter` scripts are dedicated to the public domain.
Use it as you please with no restrictions whatsoever.


## Questions? Comments?

Send them along to the
[Open Sports & Friends Forum/Mailing List](http://groups.google.com/group/opensport).
Thanks!
