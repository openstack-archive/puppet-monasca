#!/bin/sh

MIRROR_FILE="/opt/kafka/config/mirror.properties"
STORM_FILE="/opt/storm/current/conf/storm.yaml"

#
# Get the list of monasca services in the order they should be
# started in.
#
get_up_list() {
    echo "influxdb zookeeper kafka"

    if [ -e $MIRROR_FILE ]
    then
        echo "kafka-mirror"
    fi

    echo "storm-supervisor"

    if grep nimbus.host $STORM_FILE | grep $(hostname) > /dev/null
    then
        echo "storm-nimbus storm-ui monasca-thresh"
    fi

    echo "monasca-persister monasca-api"
}

#
# Get the list of monasca services in the order they should be
# stopped in.
#
get_down_list() {

    echo "monasca-api monasca-persister"

    if grep nimbus.host $STORM_FILE | grep $(hostname) > /dev/null
    then
        echo "monasca-thresh storm-ui storm-nimbus"
    fi

    echo "storm-supervisor"

    if [ -e $MIRROR_FILE ]
    then
        echo "kafka-mirror"
    fi

    echo "kafka zookeeper influxdb"
}

status() {
    for x in $(get_up_list)
    do
        service $x status
    done
}

start() {
    for x in $(get_up_list)
    do
        service $x start
        sleep 2
    done
}

stop() {
    for x in $(get_down_list)
    do
        service $x stop
        sleep 2
    done
}

tail_logs() {
    /usr/bin/tail -f /opt/storm/current/logs/*log \
                     /var/log/monasca/*log \
                     /var/log/influxdb/*log \
                     /var/log/kafka/*log \
                     /opt/kafka/logs/*log
}

tail_metrics() {
    /usr/bin/tail -f /tmp/kafka-logs/metr*/*log | /usr/bin/strings
}

case "$1" in
  status)
    status
        ;;
  start)
    start
        ;;
  stop)
    stop
        ;;
  restart)
    stop
    sleep 2
    start
        ;;
  tail-logs)
    tail_logs
        ;;
  tail-metrics)
    tail_metrics
        ;;
  *)
        echo "Usage: "$1" {status|start|stop|restart|tail-logs|tail-metrics}"
        exit 1
esac
