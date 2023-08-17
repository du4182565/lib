#!/bin/bash
pid_cnts=`ps -ef | grep frpc | grep -v grep | wc -l`
if [ $pid_cnts -eq 0 ];then
    echo "No available frpc  workker, starting one, $(date)"

   /home/ducan/soft/frp-dev/bin/frpc -c /home/ducan/soft/frp-dev/bin/frpc.ini &>/dev/null &
    sleep 3
    cnt=$(ps -ef | grep frpc | grep -v grep | wc -l)
    if [ $cnt -gt 0 ];then
       echo "Restarting frpc done."
    fi
else
   echo "frps working ok, pid_cnts = $pid_cnts, $(date)"
fi
