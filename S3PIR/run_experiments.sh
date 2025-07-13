#!/bin/bash

BINARY=./build/s3pir
RESULTS_FILE=amortized_times.csv

# Parameters to sweep
LOGDBSIZE_LIST=(16 18 20 22 24)  # (2^16, 2^17, 2^18, 2^19)
ENTRYSIZE_LIST=(2048 4096 8192)  #(2KB, 4KB, 8KB, 16KB)

# Output CSV header (overwrite previous file)
echo "LogDBSize,EntrySize,AmortizedTime_ms" > $RESULTS_FILE

for logdbsize in "${LOGDBSIZE_LIST[@]}"; do
  for entrysize in "${ENTRYSIZE_LIST[@]}"; do
    echo "Running: $BINARY --one-server $logdbsize $entrysize /results/file_256.txt"
    # Run the program and capture the output
    OUTPUT=$($BINARY --one-server $logdbsize $entrysize /results/file_256.txt)
    # Parse Amortized compute time per query
    AMORTIZED=$(echo "$OUTPUT" | grep "Amortized compute time per query" | awk '{print $6}')
    # In case the program failed, skip the row
    if [ -z "$AMORTIZED" ]; then
      echo "Run failed for LogDBSize=$logdbsize EntrySize=$entrysize"
      continue
    fi
    # Write to CSV (LogDBSize,EntrySize,AmortizedTime_ms)
    echo "$logdbsize,$entrysize,$AMORTIZED" >> $RESULTS_FILE
  done
done

echo "Experiments completed. Results in $RESULTS_FILE"
