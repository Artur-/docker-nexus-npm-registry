#!/bin/bash

echo "Populating the caches!"
cd /tmp
mkdir test-projects
cd test-projects
for tech in plain-java spring javaee
do
    npx @vaadin/cli init --tech $tech $tech
    cd plain-java
    mvn clean package
    mvn clean package -Pproduction
    cd ..
done
rm -r -f /tmp/test-projects
rm -rf ~/.m2 ~/.npm
echo
echo "================"
echo
echo "Caches populated"
echo
echo "================"
echo
