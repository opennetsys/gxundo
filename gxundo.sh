#!/bin/bash

# function to install `jq`
function install_jq {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
      sudo apt-get install jq
  elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq
  fi
}

# check if `gorep` is installed, otherwise install it.
command -v gorep >/dev/null
if [ $? -ne 0 ]; then
  echo "gorep is not installed. Installing..."
  go get github.com/novalagung/gorep && echo "gorep installed"
fi

# check if `jq` is installed, otherwise install it.
command -v jq >/dev/null
if [ $? -ne 0 ]; then
  echo "jq is not installed. Installing..."
  install_jq && echo "jq installed"
fi

# the path to search passed an the only argument
dirpath="$1"

if [[ "$dirpath" == "" ]]; then
  echo "path is required"
  exit 1
fi

echo "finding imports..."
echo "path $dirpath"

# read all Go imports that contain "gx/ipfs/"
for dir in $(find "$dirpath" -maxdepth 100 -type d)
do
  for line in $(go list -json "./$dir" | jq '.Imports' | grep 'gx/ipfs/' | sed -e 's/gx\///g' | sed -e 's/"//g' | sed -e 's/,//g' | sed -e 's/ //g')
  do
    # fetch the gx package.json and read the github url
    root="$(echo "$line" | tr "/" "\\n" | awk 'FNR <= 3 {print}' | tr '\n' '/' | sed -e s'/.$//g')"
    pkg="$(echo "$line" | tr "/" "\\n" | awk 'FNR > 3 {print}' | tr '\n' '/' | sed -e s'/.$//g')"
    jsonurl="https://gateway.ipfs.io/$root/package.json"
    echo fetching "$jsonurl"
    new="$(curl -s "$jsonurl" | jq '.gx.dvcsimport' | sed -e 's/"//g')"
    if [ "$pkg" != "" ]; then
      new="$new/$pkg"
    fi
    old="gx/$line"

    echo "$old => $new"

    # replace the imports
    gorep -path="$dir" \
        -from="$old" \
        -to="$new"
  done
done

echo "complete"

