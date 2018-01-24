#!/bin/sh

set -eux

if ! test -d vendor; then
  bundle install --path vendor/bundle
fi
bundle exec jekyll build -d public
