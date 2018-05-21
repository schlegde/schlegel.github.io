My page at
[hodler.co](http://hodler.co)

## Setup

    brew install rbenv tidy-html5 aspell
    gem install bundler
    bundle install

## Running Jekyll
Make site available at [http://localhost:4000](http://localhost:4000)

    ./run.sh

## Running tests

    ./test/spell_checker.sh

## Troubleshooting
### Nokogiri install fails on OSX during bundle install

    brew install libxml2 libxslt
    brew install libiconv
    xcode-select --install

Then run `bundle install` again
