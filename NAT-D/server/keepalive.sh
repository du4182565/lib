#!/bin/bash
pid_cnts=$(ps -ef | grep frps | grep -v grep | wc -l)
if [ $pid_cnts -eq 0 ];then
    echo "No available ultrahook worker, starting one, $(date)"
    echo "test"
    /home/ducan/frp-dev/bin/frps -c /home/ducan/frp-dev/bin/frps.ini 
    cnt=$(ps -ef | grep ultrahook | grep -v grep | wc -l)
    if [ $cnt -gt 0 ];then
       echo "Restarting frps done."
    fi
else
   echo "frps working ok, pid_cnts = $pid_cnts, $(date)"
fi
