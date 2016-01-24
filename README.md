My blog at
[blog.hodler.co](http://blog.hodler.co)

## Setup

    brew install rbenv
    gem install bundler
    bundle install

## Running Jekyll
Make site available at [http://localhost:4000](http://localhost:4000)

    jekyll serve

## Running tests

    brew install tidy-html5

## Troubleshooting
### Nokogiri install fails on OSX

    brew install libxml2 libxslt
    brew install libiconv
    xcode-select --install
