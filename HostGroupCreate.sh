#!/bin/bash
#
# Christophe TRIOMPHE 2018
# Distributed on GPLv2

METHOD=$1
SECONDPARAM=$2
THIRDPARAM=$3
FOURTHPARAM=$4
FIFTHPARAM=$5
# Detection de presence du 6eme parametre
if [ -z "$6" ]; then
	SIXTHPARAM=0
else
	SIXTHPARAM=$6
fi


# CONSTANT VARIABLES
ERROR='0'
ZABBIX_USER='SCRIPT' #Make user with API access and put name here
ZABBIX_PASS='123456' #Make user with API access and put password here
API='http://127.0.0.1/zabbix/api_jsonrpc.php' #URL of your Zabbix FrontEnd


# Authenticate with Zabbix API
authenticate() {
        echo `curl -k -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $API`
    }

# Create Host Agent
create_host_agent() {
        echo `curl -k -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\": {\"host\":\"$THIRDPARAM\",\"interfaces\": [{\"type\": 1,\"main\": 1,\"useip\": 1,\"ip\": \"$SECONDPARAM\",\"dns\": \"\",\"port\": \"10050\"}],\"groups\": [{\"groupid\": \"$FOURTHPARAM\"}],\"templates\": [{\"templateid\": \"$FIFTHPARAM\"}]},\"auth\":\"$AUTH_TOKEN\",\"id\":1}" $API`
    }

# Create Host SNMP
create_host_snmp() {
        echo `curl -k -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\": {\"host\":\"$THIRDPARAM\",\"proxy_hostid\":\"$SIXTHPARAM\",\"interfaces\": [{\"type\": 2,\"main\": 1,\"useip\": 1,\"ip\": \"$SECONDPARAM\",\"dns\": \"\",\"port\": \"161\"}],\"groups\": [{\"groupid\": \"$FOURTHPARAM\"}],\"templates\": [{\"templateid\": \"$FIFTHPARAM\"}]},\"auth\":\"$AUTH_TOKEN\",\"id\":1}" $API`
    }

# Create HostGroup
create_hostgroup() {
        echo `curl -k -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.create\",\"params\": {\"name\":\"$SECONDPARAM\"},\"auth\":\"$AUTH_TOKEN\",\"id\":1}" $API`
    }

case $1 in
        HOST-AG)
        AUTH_TOKEN=`echo $(authenticate)|jq -r .result`
        output=$(create_host_agent)
        echo $output | grep -q "hostids"
        rc=$?
        if [ $rc -ne 0 ]; then
      echo -e "Error in adding host ${SECONDPARAM} at `date`:\n"
      echo $output | grep -Po '"message":.*?[^\\]",'
      echo $output | grep -Po '"data":.*?[^\\]"'
      exit 1
        else
      echo -e "\nHost ${SECONDPARAM} added successfully\n"
      exit 0
        fi
        ;;
        HOST-SNMP)
        AUTH_TOKEN=`echo $(authenticate)|jq -r .result`
        output=$(create_host_snmp)
        echo $output | grep -q "hostids"
        rc=$?
        if [ $rc -ne 0 ]; then
      echo -e "Error in adding host ${SECONDPARAM} at `date`:\n"
      echo $output | grep -Po '"message":.*?[^\\]",'
      echo $output | grep -Po '"data":.*?[^\\]"'
      exit 1
        else
      echo -e "\nHost ${SECONDPARAM} added successfully\n"
      exit 0
        fi
        ;;
        HG)
        AUTH_TOKEN=`echo $(authenticate)|jq -r .result`
        output=$(create_hostgroup)
        echo $output | grep -q "groupids"
        rc=$?
        if [ $rc -ne 0 ]; then
      echo -e "Error in adding host ${SECONDPARAM} at `date`:\n"
      echo $output | grep -Po '"message":.*?[^\\]",'
      echo $output | grep -Po '"data":.*?[^\\]"'
      exit 1
        else
                echo -e "\nHost ${SECONDPARAM} added successfully\n"
      exit 0
        fi
        ;;
        *)
        echo "Parameter Error, use this script with (HOST-AG|HOST-SNMP|HG) (IP|IP|HOSTGROUP_NAME) (Zabbix_HOSTNAME) (HOSTGROUPID) (TEMPLATEID) (Optional PROXYID)"
        ;;
esac