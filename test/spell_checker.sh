#!/bin/sh

# check contents
spelling_errors=0
for f in $(find _site -name '*.html'); do
  echo -n "checking spelling in $f... "
  # get tidied html, redirect non html output to /dev/null
  tidy -i -asxml $f 2>/dev/null | \
    # newline after each tag
    sed 's|>|>\'$'\n|g' | \
    # newline before each tag, now every html element has a single line
    sed 's|<|\'$'\n<|g' | \
    # were only interested in paragraphs and headings
    xmllint --html --xpath '(//p|//h2|//h3|//h4)' - 2>/dev/null | \
    # remove contents of the code tag
    sed -e '/<code>/ { N; d; }' | \
    # remove all lines that start with a html tag
    grep -v '^<' | \
    aspell --ignore=2 -p ./test/aspell.en.pws pipe | \
    grep '^&'
  if [ $? -ne 1 ]; then
    ((spelling_errors++))
  else
    echo "OK"
  fi
done
if [ $spelling_errors -ne 0 ]; then
  echo "there are ${spelling_errors} problems above"
  exit -1
fi

# check titles
spelling_errors=0
for title in $(find . -regex '\./_site/[0-9]\{4\}/.*\.html'); do
  echo -n "checking $title... "
  echo $title | sed "s|[^a-zA-Z]| |g" | \
    aspell --ignore-case -p ./test/aspell.en.pws pipe | \
    grep ^\&
  if [ $? -ne 1 ]; then
    ((spelling_errors++))
  else
    echo "OK"
  fi
done
if [ $spelling_errors -ne 0 ]; then
  echo "there are ${spelling_errors} problems above"
  exit -1
fi

echo "spelling is fine"
