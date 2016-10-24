#!/bin/sh 
procServ --allow -n "SRI-XRAY" -p pid.txt -L log.txt --logstamp -i ^D^C 2001 ../../bin/$EPICS_HOST_ARCH/sri st.cmd
sleep 10
