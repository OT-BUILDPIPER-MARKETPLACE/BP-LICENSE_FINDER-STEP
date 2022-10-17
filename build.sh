#!/bin/bash
source functions.sh

logInfoMessage "I'll scan the license available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep  $SLEEP_DURATION

logInfoMessage "I've recieved below arguments $@"
cd  $WORKSPACE/${CODEBASE_DIR}

if [ -f doc/dependency_decisions.yml ]; then
  logInfoMessage "License finder dependency decision file already exists in the repo we will be using that."
  cat doc/dependency_decisions.yml
else
  logInfoMessage  "License finder dependency decision file doesn't exists in the repo we will be leveraging default dependency decision file."
  mkdir doc
  cp /tmp/dependency_decisions.yml doc/dependency_decisions.yml
fi

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