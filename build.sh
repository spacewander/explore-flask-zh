#!/bin/sh

set -x
tmpDir=$(mktemp -d -u)
gitbook build ./zh --config ./zh/book.json
mv ./zh/_book "$tmpDir"
git checkout gh-pages
cp -r -t "$tmpDir" .git
cd "$tmpDir" && git commit -a -m "$(date)" && git push origin gh-pages
