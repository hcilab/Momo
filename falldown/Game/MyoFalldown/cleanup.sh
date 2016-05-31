#!/bin/bash

set -e

source_files=`find . -name "*.pde"`

for s in $source_files; do
  sed -i '' 's! *//<>//!!g' $s
done
