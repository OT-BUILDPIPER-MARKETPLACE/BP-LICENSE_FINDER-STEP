#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

# 1. Environment Setup Phase
if test -f requirements.txt; then
  if test ${PYTHON_VERSION:-3} = "3"; then
    logInfoMessage "Configuring Python 3 environment for requirements.txt..."
    ln -sf $(which python3) $(which python)
    ln -sf $(which pip3) $(which pip)
    
    add_event "PYTHON ENV SETUP" "Successful" \
              "Configured symlinks for Python 3" \
              "Target: requirements.txt detected"
  fi
fi

# 2. Initialization Phase
logInfoMessage "Initiating License Scanner in workspace: [$WORKSPACE], codebase directory: [$CODEBASE_DIR]"
add_event "LICENSE SCAN INITIATED" "Successful" \
          "License scan started" \
          "Target Directory: $WORKSPACE/$CODEBASE_DIR"

sleep $SLEEP_DURATION

logInfoMessage "Execution arguments received: $@"
cd $WORKSPACE/${CODEBASE_DIR}

# 3. Configuration Phase
if [ -f doc/dependency_decisions.yml ]; then
  logInfoMessage "Existing dependency decision file detected in the repository. Using local configuration."
  
  add_event "DEPENDENCY CONFIGURATION" "Successful" \
            "Loaded existing repository configuration" \
            "File: doc/dependency_decisions.yml"
            
  cat doc/dependency_decisions.yml
else
  logInfoMessage "No repository dependency decision file found. Applying default configuration from /tmp."
  mkdir -p doc
  cp /tmp/dependency_decisions.yml doc/dependency_decisions.yml
  
  add_event "DEPENDENCY CONFIGURATION" "Successful" \
            "Applied default dependency configuration" \
            "Source: /tmp/dependency_decisions.yml"
fi

# 4. Execution Phase
logInfoMessage "Executing license_finder..."
license_finder

# 5. Validation and Result Phase
if [ $? -eq 0 ]
then
  logInfoMessage "License compliance check passed successfully. All licenses comply."
  
  add_event "LICENSE SCAN COMPLETE" "Successful" \
            "All dependencies comply with approved licenses" \
            "Action: PASSED"
            
  generateOutput mvn_execute true "Congratulations all licenses complied!!!"
elif [ "$VALIDATION_FAILURE_ACTION" == "FAILURE" ]
then
  logErrorMessage "License compliance check failed: Non-compliant libraries detected."
  
  add_event "LICENSE SCAN COMPLETE" "Failed" \
            "Non-compliant licenses found in dependencies" \
            "Action: BUILD FAILED (Strict Mode)"
            
  generateOutput mvn_execute false "Please check some libraries have non-compliant licences!!!!!"
  logErrorMessage "Build unsuccessful due to license violations."
  exit 1
else
  logWarningMessage "License compliance check finished with warnings: Non-compliant libraries detected, but build is configured to proceed."
  
  add_event "LICENSE SCAN COMPLETE" "Successful" \
            "Non-compliant licenses found in dependencies" \
            "Action: PROCEEDING (Warning Mode)"

            
  generateOutput mvn_execute true "Please check some libraries have non-compliant licences!!!!!"
fi