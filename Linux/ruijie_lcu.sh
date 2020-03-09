#!/bin/bash

#If received logout parameter, sned a logout request to eportal server
if [ "$1" = "logout" ]; then
  userIndex=`curl -s -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36" -I http://172.30.2.2:8088/eportal/redirectortosuccess.jsp | grep -o 'userIndex=.*'`
  logoutResult=`curl -s -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36" -d "$userIndex" http://172.30.2.2:8088/eportal/InterFace.do?method=logout`
  echo $logoutResult
  exit 0
fi

#If received parameters is less than 2, print usage
if [ "$#" -lt "2" ]; then
  echo "Usage: ./ruijie_lcu.sh username password"
  echo "Example: ./ruijie_lcu.sh 2016200000 123456"
  echo "if you want to logout, use: ./ruijie_lcu.sh logout"
  exit 1
fi

#Exit the script when is already online, use connect.rom.miui.com/generate_204 to check the online status
captiveReturnCode=`curl -s -I -m 10 -o /dev/null -s -w %{http_code} http://connect.rom.miui.com/generate_204`
if [ "$captiveReturnCode" = "204" ]; then
  echo "You are already online!"
  exit 0
fi

#If not online, begin Ruijie Auth

#Get Ruijie login page URL
loginPageURL=`curl -s "http://connect.rom.miui.com/generate_204" | awk -F \' '{print $2}'`

#Structure loginURL
loginURL=`echo $loginPageURL | awk -F \? '{print $1}'`
loginURL="${loginURL/index.jsp/InterFace.do?method=login}"

#Structure quertString
queryString=`echo $loginPageURL | awk -F \? '{print $2}'`
queryString="${queryString//&/%2526}"
queryString="${queryString//=/%253D}"

#Send Ruijie eportal auth request and output result
if [ -n "$loginURL" ]; then
  authResult=`curl -s -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36" -e "$loginPageURL" -b "EPORTAL_COOKIE_USERNAME=; EPORTAL_COOKIE_PASSWORD=; EPORTAL_COOKIE_SERVER=; EPORTAL_COOKIE_SERVER_NAME=; EPORTAL_AUTO_LAND=false; EPORTAL_USER_GROUP=null; EPORTAL_COOKIE_OPERATORPWD=;" -d "userId=$1&password=$2&service=&queryString=$queryString&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" "$loginURL"`
  echo $authResult
fi
