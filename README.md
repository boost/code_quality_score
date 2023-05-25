# CodeQualityScore

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/code_quality_score`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

- Add the gem
- Bundle install
- `bundle binstubs code_quality_score`


## Usage

`bin/code_quality_score` # assumes it is an app, not a gem, and you are running it from the directory of the repository.

`bin/code_quality_score lib ../my-repo/` # first argument is the folder where the source code is expected to be. Defaults to "app". Second argument is the relative directory of the repository.  Defaults to "./" 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/code_quality_score.
