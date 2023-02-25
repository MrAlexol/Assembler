#!/bin/bash

WORK_FOLDER="test/HW2"
EXEC_FILE="HW 2/main"
OUTPUT_FILE="${WORK_FOLDER}/test-result.out"

echo "Start" > $OUTPUT_FILE

for file in $WORK_FOLDER/*.test
do
    echo "=== ${file} ===" >> "${OUTPUT_FILE}"
    cat ${file} >> "${OUTPUT_FILE}"
    echo "--- Test --->" >> "${OUTPUT_FILE}"
    (cat ${file} | "${EXEC_FILE}") &>> "${OUTPUT_FILE}"
done

diff $OUTPUT_FILE $WORK_FOLDER/test-result.sample

