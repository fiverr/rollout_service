#!/bin/bash

PID_FILE=./pid/unicorn.pid
UNICORN_CFG="./etc/rollout_service_unicorn.rb"

echo "Working with unicorn script: $UNICORN_CFG."

PREFIX="[HOST:$(hostname)]"


# Set GC properties
export RUBY_HEAP_MIN_SLOTS=600000
export RUBY_GC_MALLOC_LIMIT=30000000
export RUBY_HEAP_FREE_MIN=100000

sig () {
  kill -$1 $2
}

check_it_out () {
    COUNTER=0
    APP_CHECK="$1"
    SUCC_PARAM="$2"     # Success parameter [eq / ne] to empty string
    TOP=$3              # Number of Try cycles
    SLEEP=$4            # Sleep period (sec)
    SUCCESS=0
    while [ "$SUCCESS" != "1" ] && [ $COUNTER -lt $TOP ]; do
        let COUNTER=COUNTER+1
        echo -e "."
        CHECK=$(ps aux | grep "$UNICORN_CFG" | grep "$APP_CHECK")
        if [ "$CHECK" == "" ] && [ "$SUCC_PARAM" == "eq" ]; then
            let SUCCESS="1";
        elif [ "$CHECK" != "" ] && [ "$SUCC_PARAM" == "ne" ]; then
            let SUCCESS="1";
        else
            sleep $SLEEP;
        fi
    done
}

case "$1" in
        start)
                if [ "$2" == "" ]; then
                    echo >&2 "Usage: $0 start <ENV>"
                    exit 1
                fi
                echo -e "$PREFIX Checking if there's a unicorn running: "
                OLD_PID=$(ps aux | grep "$UNICORN_CFG" | grep master | awk '{print $2}')
                STALE_WORKER=$(ps aux | grep "$UNICORN_CFG" | grep worker | grep -v start)
                if [ "$OLD_PID" != "" ]; then
                    echo >&2 "$PREFIX Unicorn is already running (Master PID $OLD_PID)" && exit 1
                elif [ "$STALE_WORKER" != "" ]; then
                    echo >&2 "$PREFIX There's a running unicorn in the wild (workers w/o a master), please check your machine" && exit 1
                else
                    echo -e "$PREFIX Starting unicorn:"
                    [ -f $PID_FILE ] && rm $PID_FILE
                    bundle exec unicorn -c $UNICORN_CFG -E $2 -D
                    check_it_out worker ne 9 10 # Success when there's a unicorn worker (process -ne empty string)
                    if [ "$SUCCESS" -ne 1 ]; then
                        echo >&2 "$PREFIX Something went wrong. Fix the problem and try again" && exit 1
                    else
                        MASTER_PID=$(ps aux | grep "$UNICORN_CFG" | grep master | awk '{print $2}')
                        echo "$PREFIX [OK]. Unicorn started (Master PID $MASTER_PID)." && exit 0
                    fi
                fi
                ;;
        stop)
                echo -e "$PREFIX Getting PID: "
                OLD_PID=$(ps aux | grep "$UNICORN_CFG" | grep master | awk '{print $2}')
                if [ "$OLD_PID" != "" ]; then
                    echo -e "$PREFIX Stoping unicorn (master PID $OLD_PID):"
                    sig QUIT $OLD_PID
                    check_it_out master eq 6 3 # Success when there's NO app unicorn master (process -eq empty string)
                    if [ "$SUCCESS" -ne 1 ]; then
                        echo >&2 "$PREFIX Couldn't stop unicorn. FIX what you broke and try again " && exit 1
                    else
                        [ -f $PID_FILE ] && rm $PID_FILE
                        echo "$PREFIX [OK]. Unicorn stopped." && exit 0
                    fi
                else
                    echo >&2 "$PREFIX There's no unicorn up to stop." && exit 0
                fi
                ;;
        restart) # good to have $2 = environment for case where there's no unicorn up
                echo -e "$PREFIX Getting PID: "
                OLD_PID=$(ps aux | grep "$UNICORN_CFG" | grep master | awk '{print $2}')
                if [ "$OLD_PID" != "" ]; then
                    echo -e "$PREFIX Restarting unicorn (Old Master PID $OLD_PID):"
                    sig USR2 $OLD_PID
                    check_it_out $OLD_PID eq 9 10 # Success when there's NO unicorn with the old master pid (process -eq empty string)
                    if [ "$SUCCESS" -ne 1 ]; then
                        echo >&2 "$PREFIX Something went wrong. Fix the problem and try again " && exit 1
                    else
                        MASTER_PID=$(ps aux | grep "$UNICORN_CFG" | grep master | awk '{print $2}')
                        echo "$PREFIX [OK]. Unicorn restarted (New Master PID $MASTER_PID)." && exit 0
                    fi
                else
                    echo >&2 "$PREFIX There's no unicorn up to restart, Trying to start a new one:"
                    $0 start $2 $3
                fi
                ;;
        status)
                ;;
        *)
                echo "Usage: $0 {start|stop|restart|status}"
                ;;
esac
