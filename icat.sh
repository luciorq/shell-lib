#!/usr/bin/env bash

# Open images at the terminal
# + if kitty API is available use
# + icat kitten
function icat () {
  kitty +kitten icat "$@";

}
