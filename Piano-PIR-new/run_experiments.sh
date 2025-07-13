#!/bin/bash

RESULTS_FILE=go_pir_amortized_times.csv
SERVER_GO="server/server.go"
CLIENT_GO="client_new/client_new.go"
UTIL_GO="util/util.go"
CONFIG_TXT="config.txt"

# Edit these lists for your sweep
LOGDBSIZE_LIST=(16 18 20 22 24)  # (2^16, 2^17, 2^18, 2^19)
ENTRYSIZE_LIST=(2048 4096 8192)  #(2KB, 4KB, 8KB, 16KB)

echo "LogDBSize,EntrySize,AmortizedTime_ms" > $RESULTS_FILE

for logdbsize in "${LOGDBSIZE_LIST[@]}"; do
  N=$((2 ** logdbsize))
  for entrysize in "${ENTRYSIZE_LIST[@]}"; do
    # Write config.txt
    echo "$N 42" > $CONFIG_TXT  # 42 as seed; change if needed

    # Edit util.go for entry size (replace the constant line)
    sed -i.bak "s/const DBEntrySize = .*/const DBEntrySize = $entrysize/" "$UTIL_GO"

    # Kill any previous server on port 50051
    lsof -ti :50051 | xargs kill 2>/dev/null
    sleep 2`1`1 
    # Wait until port is free
    while lsof -i :50051 >/dev/null; do sleep 1; done

    #Kill any previous server
    pkill -f "go run $SERVER_GO"
    sleep 2

    # Start server in background
    go run $SERVER_GO -port 50051 &
    SERVER_PID=$!
    sleep 2  # Wait for server to start

    # Run client and capture output
    OUTPUT=$(go run $CLIENT_GO -ip localhost:50051 -thread 1 2>&1)
    AMORTIZED=$(echo "$OUTPUT" | grep 'Online Phase took' | awk -F'amortized time ' '{print $2}' | awk '{print $1}')

    # Save result
    if [ -n "$AMORTIZED" ]; then
      echo "$logdbsize,$entrysize,$AMORTIZED" >> $RESULTS_FILE
    else
      echo "Run failed for LogDBSize=$logdbsize EntrySize=$entrysize"
    fi

    # 7. Kill server after each run
    kill $SERVER_PID
    sleep 2
  done
done

echo "All experiments completed. Results in $RESULTS_FILE"
