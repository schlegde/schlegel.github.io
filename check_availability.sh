#!/bin/sh

mark_failed() {
  echo "an availability command has failed"
  exit 1
}

# is available
test `curl -I https://www.hodler.co | head -n 1 | cut -d ' ' -f2` -eq 200 || mark_failed
# redirects to https
test `curl -I hodler.co | head -n 4 | tail -n 1 | cut -d ' ' -f2` =~ ^https://www.hodler.co.* || mark_failed
