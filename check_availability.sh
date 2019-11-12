#!/bin/sh

mark_failed() {
  echo "an availability command has failed"
  exit 1
}

# is available
test `curl -I https://www.hodler.co | head -n 1 | cut -d ' ' -f2` -eq 200 || mark_failed
# redirects to https
REDIRECTED_TO=`curl -I hodler.co | head -n 4 | tail -n 1 | cut -d ' ' -f2`
if [[ "$REDIRECTED_TO" =~ ^https://www.hodler.co.* ]]; then
  echo "redirects to https"
else
  echo mark_failed
fi
