#!/bin/bash
source functions.sh

echo "I'll scan the license available at [$WORKSPACE] and have mounted at [$CODEBASE_DIR]"
sleep  $SLEEP_DURATION

cd  $WORKSPACE/${CODEBASE_DIR}
license_finder action_items

if [ $? -eq 0 ]
then
  generateOutput mvn_execute true "Congratulations build succeeded!!!"
  echo "build sucessfull"
elif  [ $? != 0 ]
then 
  generateOutput mvn_execute false "Build failed please check!!!!!"
  echo "build unsucessfull"
  exit 1
fi