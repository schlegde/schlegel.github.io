#!/bin/sh

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
