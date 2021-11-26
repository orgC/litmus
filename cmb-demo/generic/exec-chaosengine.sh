#!/bin/bash

if [ $# -ne 2 ];then
   echo "$0 <experiment_name> <start/activate/result/stop>"
   exit 1
fi

experiment_name=$1
command=$2

if [ $command == "start" ];then
  oc apply -f $experiment_name/rbac.yaml
  oc apply -f $experiment_name/engine.yaml
  echo "CTRL + C to terminate"
  watch oc get pod
fi

if [ $command == "activate" ];then
   engine_name=$(grep ChaosEngine -A2 $experiment_name/engine.yaml|grep name|awk '{print $2}')
  oc patch chaosengine $engine_name --type merge --patch '{"spec":{"engineState":"active"}}'
fi

if [ $command == "result" ];then
   engine_name=$(grep ChaosEngine -A2 $experiment_name/engine.yaml|grep name|awk '{print $2}')
   oc describe chaosresult $engine_name-$experiment_name
fi

if [ $command == "stop" ];then
  oc delete -f $experiment_name/rbac.yaml
  oc delete -f $experiment_name/engine.yaml
fi
