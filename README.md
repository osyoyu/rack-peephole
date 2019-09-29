# Rack::Peephole

Rack::Peephole is a Rack middleware inspired by [google/pprof](https://github.com/google/pprof), which injects 'peephole' endpoints for collecting CPU profiles.
`GET /peephole/cpu` and `GET /peephome/wall` are provided for collecting CPU time profiles and wall time profiles, respectively.


## Installation

Add `gem 'rack-peephole'` to your Gemfile, and add this line to config.ru:

```ruby
use Rack::Peephole
```


## Usage

Now that your app has mounted Rack::Peephole, run:

```
$ curl http://localhost:3000/peephole/cpu > profile.dump
```

[StackProf](https://github.com/tmm1/stackprof) will be spawned to collect CPU profiles.
After 30 seconds, Rack::Peephole will stop profiling, and will return the collected dumps.

Visualization can be done using the `stackprof` utility  (see https://github.com/tmm1/stackprof for more instructions):

```
$ stackprof --d3-flamegraph profile.dump > flamegraph.html
```


## Options
TBD


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/putsprof.
