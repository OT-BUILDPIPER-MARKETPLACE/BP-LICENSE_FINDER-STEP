#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

if test -f requirements.txt; then
  if test ${PYTHON_VERSION:-3} = "3"; then
    ln -sf $(which python3) $(which python)
    ln -sf $(which pip3) $(which pip)
  fi
fi

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
  logInfoMessage "Congratulations all licenses complied!!!"
  generateOutput mvn_execute true "Congratulations all licenses complied!!!"
elif [ $VALIDATION_FAILURE_ACTION == "FAILURE" ]
  then
    logErrorMessage "Please check some libraries have non-compliant licences!!!"
    generateOutput mvn_execute false "Please check some libraries have non-compliant licences!!!!!"
    logErrorMessage "build unsucessfull"
    exit 1
   else
    logWarningMessage "Please check some libraries have non-compliant licences!!!"
    generateOutput mvn_execute true "Please check some libraries have non-compliant licences!!!!!"
fi
