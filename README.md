My blog at
[blog.hodler.co](http://blog.hodler.co)

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
### Nokogiri install fails on OSX

    brew install libxml2 libxslt
    brew install libiconv
    xcode-select --install
