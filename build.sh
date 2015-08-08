#!/bin/sh

thisProject="explore-flask-zh"
tmpDir=$(mktemp -d)
gitbook build ./zh --output="$tmpDir" --config ./zh/book.json
git checkout gh-pages
cp -r .git "$tmpDir"
cd .. && rm -rf "$thisProject" && mv "$tmpDir" "$thisProject"
git commit -a -m "$(date)"
git push origin gh-pages
