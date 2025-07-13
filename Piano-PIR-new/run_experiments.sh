#!/bin/bash

RESULTS_FILE=go_pir_amortized_times.csv
SERVER_GO="server/server.go"
CLIENT_GO="client_new/client_new.go"
UTIL_GO="util/util.go"
CONFIG_TXT="config.txt"

# Edit these lists for your sweep (add more as needed)
LOGDBSIZE_LIST=(16 17 18)    # Try: 16, 17, 18
ENTRYSIZE_LIST=(8 32 256)    # Try: 8, 32, 256 (must be multiple of 8!)

echo "LogDBSize,EntrySize,AmortizedTime_ms" > $RESULTS_FILE

# Backup util.go ONCE
cp "$UTIL_GO" "$UTIL_GO.orig"

for logdbsize in "${LOGDBSIZE_LIST[@]}"; do
  N=$((2 ** logdbsize))
  for entrysize in "${ENTRYSIZE_LIST[@]}"; do

    echo "========== Running for LogDBSize=$logdbsize, EntrySize=$entrysize, N=$N =========="
    echo "$N 42" > $CONFIG_TXT
    cat $CONFIG_TXT

    # Edit DBEntrySize in util.go (make sure to match your line exactly!)
    sed -i.bak "s/DBEntrySize[[:space:]]*=[[:space:]]*[0-9]\+/DBEntrySize   = $entrysize/" "$UTIL_GO"

    # Kill previous server(s) and wait for port to free up
    lsof -ti :50051 | xargs kill 2>/dev/null
    sleep 2
    while lsof -i :50051 >/dev/null; do sleep 1; done

    # Logging files (unique per run)
    RUN_ID="${logdbsize}_${entrysize}_$(date +%s)"
    SERVER_LOG="server_log_$RUN_ID.txt"
    CLIENT_LOG="client_log_$RUN_ID.txt"

    # Start server in background, redirect output to log
    nohup go run $SERVER_GO -port 50051 > "$SERVER_LOG" 2>&1 &
    SERVER_PID=$!
    sleep 2

    # Run client and log output
    go run $CLIENT_GO -ip localhost:50051 -thread 1 > "$CLIENT_LOG" 2>&1
    OUTPUT=$(cat "$CLIENT_LOG")

    # Extract amortized time (online phase)
    AMORTIZED=$(echo "$OUTPUT" | grep 'Online Phase took' | awk -F'amortized time ' '{print $2}' | awk '{print $1}')

    if [ -n "$AMORTIZED" ]; then
      echo "$logdbsize,$entrysize,$AMORTIZED" >> $RESULTS_FILE
      echo "Result: LogDBSize=$logdbsize, EntrySize=$entrysize, AmortizedTime_ms=$AMORTIZED"
    else
      echo "Run failed for LogDBSize=$logdbsize EntrySize=$entrysize"
    fi

    kill $SERVER_PID
    sleep 2
    while lsof -i :50051 >/dev/null; do sleep 1; done

    # (Optional) Clean up .bak files after each run
    rm -f "$UTIL_GO.bak"
  done
done

# Restore original util.go at the end
mv "$UTIL_GO.orig" "$UTIL_GO"

echo "All experiments completed. Results in $RESULTS_FILE"
