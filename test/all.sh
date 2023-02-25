#!/bin/bash

for dir in "Lab 1" "Lab 2" "Lab 3"
do
    cd "${dir}"
    make translate
    cd ..
done

for file in test/*test.sh
do
    chmod +x ${file}
    ${file}
    if [ $? -eq 0 ]
    then
        printf "\033[32m\033[1m${file} - success\033[0m\n"
    else
        printf "\033[41m\033[1m\033[30m${file} - failed!\033[0m\n"
    fi
done
