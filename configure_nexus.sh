#!/bin/bash

file="/nexus-data/admin.password"

# wait for admin.password file in nexus folder
while [ ! -f "$file" ]
do
    echo "admin.password doesn't exist yet"
    sleep 10s
done
echo "admin.password exist! Let's wait for nexus webservice"

# change REST URI in script file
sed -i "s|/service/siesta/rest/v1/script/|/service/rest/v1/script/|g" /tmp/change_password_script/change_admin_password.sh

# set script as source so you can use its methods
source /tmp/change_password_script/change_admin_password.sh 

# change password
CHANGE_ADMIN_PASSWORD_STATUS="" ;
while [[ ${CHANGE_ADMIN_PASSWORD_STATUS} != *"succeeded!" ]] && [[ ${CHANGE_ADMIN_PASSWORD_STATUS} != *"Unauthorized (401)" ]]
do
    sleep 10s
    echo "webservice not running yet: ${CHANGE_ADMIN_PASSWORD_STATUS}"
    CHANGE_ADMIN_PASSWORD_STATUS=`change_admin_password localhost:8081 $(cat /nexus-data/admin.password) admin123 -k`
done
echo "webservice is running!"

if [[ ${CHANGE_ADMIN_PASSWORD_STATUS} == *"succeeded!" ]]
then
  # this happens on first run. On subsequent runs the password is already set
  
  # go to folder with scripts for npm registry creation and set anomynous login to true
  cd /tmp/nexus-scripting-examples-master/simple-shell-example/

  # create npm registry
  sh create.sh npm.json
  sh run.sh npm

  # set anomynous to true
  sh setAnonymous.sh true

  # Trigger cache populating script
  sh /tmp/populate_caches.sh
fi

