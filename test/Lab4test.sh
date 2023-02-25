#!/bin/bash

WORK_FOLDER="test/Lab4"
EXEC_FILE="Lab 4/lab4"
OUTPUT_FILE="${WORK_FOLDER}/test-result.out"

echo "Start" > $OUTPUT_FILE

for file in $WORK_FOLDER/*.test
do
    echo "=== ${file} ===" >> "${OUTPUT_FILE}"
    cat ${file} >> "${OUTPUT_FILE}"
    echo "--- Test --->" >> "${OUTPUT_FILE}"
    (cat ${file} | "${EXEC_FILE}") &>> "${OUTPUT_FILE}"
done

[ $(grep -c "Segmentation fault      (core dumped)" "${OUTPUT_FILE}") -eq 2 ] && \
sed -z 's/\n/ /g' "${OUTPUT_FILE}" | grep "Incoming parameters: -1	90	20	30	-9	0	 11	12	13	14	15	8	 99	96	-9	-3	20	3	 -4	80	85	84	34	2	 The result is -10	90	20	30	-9	0	 0	12	13	14	15	8	 -12	96	-9	-3	20	3	 -4	80	85	84	34	2	" > /dev/null
sed -z 's/\n/ /g' "${OUTPUT_FILE}" | grep "Incoming parameters: 1000	1234	8654	3489	-999	6583	 -645	3175	-215	-140	6598	0	 2000	2001	2002	2003	2004	0	 5000	-500	-600	-400	-500	-222	 The result is -999	1234	8654	3489	-999	6583	 -1000	3175	-215	-140	6598	0	 0	2001	2002	2003	2004	0	 -2222	-500	-600	-400	-500	-222	" > /dev/null
sed -z 's/\n/ /g' "${OUTPUT_FILE}" | grep "Incoming parameters: -2	-4	-6	-8	-5	-5	 10	32	45	65	76	-7	 -3	54	-9	47	-1	90	 -1	34	45	56	67	78	 The result is -30	-4	-6	-8	-5	-5	 -7	32	45	65	76	-7	 -13	54	-9	47	-1	90	 -1	34	45	56	67	78	" > /dev/null
