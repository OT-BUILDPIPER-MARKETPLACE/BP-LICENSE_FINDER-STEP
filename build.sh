#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh
source ./BP-BASE-SHELL-STEPS/functions.sh

# ---------------------------------------------------------------
# NOTE: ACTIVITY_SUB_TASK_CODE is managed by the BuildPiper
#       environment. Do NOT override it here to ensure events
#       appear correctly in the UI.
# ---------------------------------------------------------------

WORKSPACE="${WORKSPACE:-/bp/workspace}"
CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"

if [ "$DEBUG" = true ]; then
  set -x
fi

# ---------------------------------------------------------------
# 1. Initialization
# ---------------------------------------------------------------
logInfoMessage "> Starting step: license_finder"
logInfoMessage "> Codebase location: ${CODEBASE_LOCATION}"

add_event "INITIALIZATION" "Successful" \
    "License Finder step initialized" \
    "Codebase: ${CODEBASE_DIR} | Workspace: ${WORKSPACE}"

if [ -n "$SLEEP_DURATION" ] && [ "$SLEEP_DURATION" -gt 0 ] 2>/dev/null; then
    logInfoMessage "> Sleeping for ${SLEEP_DURATION} second(s)..."
    sleep "$SLEEP_DURATION"
fi

# ---------------------------------------------------------------
# 2. Python Environment Setup
# ---------------------------------------------------------------
if test -f requirements.txt; then
    if test "${PYTHON_VERSION:-3}" = "3"; then
        logInfoMessage "> requirements.txt detected — configuring Python 3 environment..."
        ln -sf "$(which python3)" "$(which python)"
        ln -sf "$(which pip3)" "$(which pip)"
        logInfoMessage "> Python 3 symlinks configured"
        add_event "PYTHON_ENV_SETUP" "Successful" \
            "Configured symlinks for Python 3" \
            "python -> python3 | pip -> pip3"
    fi
fi

# ---------------------------------------------------------------
# 3. Workspace Navigation
# ---------------------------------------------------------------
logInfoMessage "> Navigating to codebase directory..."

cd "${CODEBASE_LOCATION}" || {
    logErrorMessage "> Failed to navigate to codebase directory: ${CODEBASE_LOCATION}"
    add_event "WORKSPACE_NAVIGATION" "Failed" \
        "Cannot change to codebase directory" \
        "Path: ${CODEBASE_LOCATION} | Verify WORKSPACE and CODEBASE_DIR"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1
}

logInfoMessage "> Successfully navigated to: ${CODEBASE_LOCATION}"
add_event "WORKSPACE_NAVIGATION" "Successful" \
    "Navigated to codebase directory" \
    "Path: ${CODEBASE_LOCATION}"

# ---------------------------------------------------------------
# 4. Dependency Configuration
# ---------------------------------------------------------------
echo ""
echo "> License Finder Execution Summary"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Parameter" "Value"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Codebase" "${CODEBASE_DIR}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
printf '| %-28s | %-48s |\n' "Failure Action" "${VALIDATION_FAILURE_ACTION:-WARNING}"
printf '+%-30s+%-50s+\n' '------------------------------' '--------------------------------------------------'
echo ""

if [ -f doc/dependency_decisions.yml ]; then
    logInfoMessage "> Existing dependency decision file found in repository — using local configuration"
    add_event "DEPENDENCY_CONFIGURATION" "Successful" \
        "Using repository dependency configuration" \
        "File: doc/dependency_decisions.yml"
    cat doc/dependency_decisions.yml
else
    logInfoMessage "> No dependency decision file found — applying default configuration from /tmp"
    mkdir -p doc
    cp /tmp/dependency_decisions.yml doc/dependency_decisions.yml
    add_event "DEPENDENCY_CONFIGURATION" "Successful" \
        "Applied default dependency configuration" \
        "Source: /tmp/dependency_decisions.yml → doc/dependency_decisions.yml"
fi

# ---------------------------------------------------------------
# 5. License Finder Execution
# ---------------------------------------------------------------
logInfoMessage "> Running license_finder scan..."
add_event "LICENSE_SCAN_START" "Successful" \
    "Starting license compliance scan" \
    "Codebase: ${CODEBASE_DIR}"

license_finder
TASK_STATUS=$?

# ---------------------------------------------------------------
# 6. Result Evaluation
# ---------------------------------------------------------------
if [ "${TASK_STATUS}" -eq 0 ]; then
    logInfoMessage "> License compliance check passed — all dependencies comply"
    add_event "LICENSE_SCAN_RESULT" "Successful" \
        "All dependencies comply with approved licenses" \
        "Status: PASSED"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} true "Congratulations all licenses complied!!!"
    saveTaskStatus 0 "${ACTIVITY_SUB_TASK_CODE}"

elif [ "${VALIDATION_FAILURE_ACTION}" == "FAILURE" ]; then
    logErrorMessage "> License compliance check FAILED — non-compliant libraries detected"
    add_event "LICENSE_SCAN_RESULT" "Failed" \
        "Non-compliant licenses found in dependencies" \
        "Status: FAILED | Action: FAILURE (strict mode)"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} false "Please check some libraries have non-compliant licences!!!!!"
    saveTaskStatus 1 "${ACTIVITY_SUB_TASK_CODE}"
    exit 1

else
    logWarningMessage "> License compliance check finished with warnings — non-compliant libraries detected but build is configured to proceed"
    add_event "LICENSE_SCAN_RESULT" "Successful" \
        "Non-compliant licenses found but build proceeding" \
        "Status: WARNING | Action: ${VALIDATION_FAILURE_ACTION:-WARNING mode}"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} true "Please check some libraries have non-compliant licences!!!!!"
    saveTaskStatus 0 "${ACTIVITY_SUB_TASK_CODE}"
fi