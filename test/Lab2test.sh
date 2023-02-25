#!/bin/bash

WORK_FOLDER="test/Lab2"
EXEC_FILE="Lab 2/lab2"
OUTPUT_FILE="${WORK_FOLDER}/test-result.out"

echo "Start" > $OUTPUT_FILE

for file in $WORK_FOLDER/*.test
do
    echo "=== ${file} ===" >> "${OUTPUT_FILE}"
    cat ${file} >> "${OUTPUT_FILE}"
    echo "--- Test --->" >> "${OUTPUT_FILE}"
    (cat ${file} | "${EXEC_FILE}") &>> "${OUTPUT_FILE}"
done

[ $(grep -c "Floating point exception(core dumped)" "${OUTPUT_FILE}") -eq 2 ] && \
grep -A1 "a = 30; b = 40; c = 60; y = 0" "${OUTPUT_FILE}" | grep "The result is s = 892,333" > /dev/null && \
grep -A1 "a = 30; b = 40; c = 60; y = 190" "${OUTPUT_FILE}" | grep "The result is s = 831,6" > /dev/null && \
grep -A1 "a = -30; b = -40; c = -60; y = -190" "${OUTPUT_FILE}" | grep "The result is s = 970,187" > /dev/null
