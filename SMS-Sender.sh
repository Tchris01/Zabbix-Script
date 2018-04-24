#!/bin/bash
#Identifiant Passerelle SMS MultiTech Rcell100
USERSMS=zabbix
PWDSMS=Pwdzabbix1
IPSMS=1.2.3.4

#Detection des Variables
INPUTMSG="$*"

#Extraction du numero de telephone mobile
DEST=$(echo "$INPUTMSG" | /usr/bin/cut -d " " -f1)

#Extraction du Message
MESSAGE=${INPUTMSG//$DEST}

#Traduction automatique des espaces
MESSAGE=${MESSAGE// /%20}

#Programme principale
if [ ! "$DEST" = "" ] && [ ! "$MESSAGE" = "" ]; then
        wget -O /tmp/Token.txt "https://$IPSMS/api/login?username=$USERSMS&password=$PWDSMS" --no-check-certificate  > /var/log/zabbix/SMS-Sended.log 2<&1
        TOKENSMS=$(/bin/cat /tmp/Token.txt | /bin/grep token | /usr/bin/cut -d ":" -f2 | /usr/bin/cut -d "\"" -f2 )
        wget -O /tmp/Inbox.txt  https://$IPSMS/api/sms/inbox?token=$TOKENSMS --no-check-certificate  > /var/log/zabbix/SMS-Sended.log 2<&1
        wget -O /tmp/outbox.txt 'https://'$IPSMS'/api/sms/outbox?data={"recipients": ["'$DEST'"], "message": "'$MESSAGE'"}&token='$TOKENSMS'&method=POST'  --no-check-certificate  > /var/log/zabbix/SMS-Sended.log 2<&1
else
        echo "Parametre manquant"  > /var/log/zabbix/SMS-Sended.log 2<&1
        exit 1
fi
/bin/rm -f /tmp/Token.txt /tmp/Inbox.txt /tmp/outbox.txt
exit 0
