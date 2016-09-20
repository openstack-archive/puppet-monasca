#!/bin/bash

MONASCA_TABLES="\
  MonMetrics.Dimensions \
  MonMetrics.Definitions \
  MonMetrics.DefinitionDimensions \
  MonMetrics.Measurements \
  MonAlarms.StateHistory"


for table in $MONASCA_TABLES
do
  /usr/sbin/vsql -c "select analyze_statistics('$table');"
done
