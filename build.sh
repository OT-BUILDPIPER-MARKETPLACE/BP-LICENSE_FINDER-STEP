#!/bin/bash
source functions.sh

logInfoMessage "I'll scan the license available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep  $SLEEP_DURATION

logInfoMessage "I've recieved below arguments $@"
cd  $WORKSPACE/${CODEBASE_DIR}

mkdir doc
cp /tmp/dependency_decisions.yml doc/dependency_decisions.yml

bash -lc "license_finder"

if [ $? -eq 0 ]
then
  logInfoMessage "Congratulations all licencses complied!!!"
  generateOutput mvn_execute true "Congratulations build succeeded!!!"
  echo "build sucessfull"
elif  [ $? != 0 ]
then 
  logErrorMessage "Please check some libraries have non-complian licences!!!"
  generateOutput mvn_execute false "Build failed please check!!!!!"
  echo "build unsucessfull"
  exit 1
fi