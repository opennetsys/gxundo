#!/bin/bash

function install_jq() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
      sudo apt-get install jq
  elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq
  fi
}

command -v gorep >/dev/null
if [ $? -ne 0 ]; then
  echo "gorep is not installed. Installing..."
  go get github.com/novalagung/gorep && echo "gorep installed"
fi

command -v jq >/dev/null
if [ $? -ne 0 ]; then
  echo "jq is not installed. Installing..."
  install_jq && echo "jq installed"
fi

dirpath="$1"

if [[ "$dirpath" == "" ]]; then
  echo "path is required"
  exit 1
fi

echo "finding imports..."
echo "path $dirpath"

for line in $(go list  -json ./...  | jq '.Imports' | grep 'gx/ipfs/' | sed -e 's/gx\///g' | sed -e 's/"//g' | sed -e 's/,//g' | sed -e 's/ //g')
do
  old="gx/$line"
  new=$(curl -s "https://gateway.ipfs.io/$line/package.json" | jq '.gx.dvcsimport' | sed -e 's/"//g')

  echo "$old => $new"

  gorep -path="$dirpath" \
      -from="$old" \
      -to="$new"
done

echo "complete"

