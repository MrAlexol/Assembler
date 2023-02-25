#!/bin/bash

for dir in "Lab 2"
do
    cd "${dir}"
    make translate
    cd ..
done

for file in test/*test.sh
do
    chmod +x ${file}
    ${file}
done
