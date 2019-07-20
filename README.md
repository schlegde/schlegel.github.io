My page at
[hodler.co](http://hodler.co)

No impressum because its a private page.

## Setup macOS

    brew install rbenv tidy-html5 aspell
    gem install bundler
    bundle install

## Setup Fedora

    dnf install ruby-devel gcc-c++ aspell aspell-en tidy-html5
    gem install bundler
    bundle install

## Running Jekyll
Make site available at [http://localhost:4000](http://localhost:4000)

    ./run.sh

## Running tests

    ./test/spell_checker.sh

## Graphviz files

Generate svgs via

    dot -Tsvg input.gv -o output.svg

## Troubleshooting
### Nokogiri install fails on OSX during bundle install

    brew install libxml2 libxslt
    brew install libiconv
    xcode-select --install

Then run `bundle install` again
