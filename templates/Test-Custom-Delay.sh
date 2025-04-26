#!/bin/bash
#start-params
#<b>Test Shell Sript that performs a set of sleep statements</b><br/>
#<br/><b>Parameters</b><br/>
#<b>Param 1</b> - Sleep value in Secs<br/>
#<b>Param 2</b> - Sleep value in Secs<br/>
#<b>Param 3</b> - Sleep value in Secs<br/>
#<b>Param 4</b> - Sleep value in Secs<br/>
#<b>Param 5</b> - Sleep value in Secs<br/>
#end-params
echo STARTED
echo "Stage 1 - Sleeping for $1"
sleep $1
echo "Stage 2 - Sleeping for $2"
sleep $2
echo "Stage 3 - Sleeping for $3"
sleep $3
echo "Stage 4 - Sleeping for $4"
sleep $4
echo "Stage 5 - Sleeping for $5"
sleep $5
echo "final stage"
echo COMPLETED
