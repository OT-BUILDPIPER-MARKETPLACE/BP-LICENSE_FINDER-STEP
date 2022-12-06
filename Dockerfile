FROM licensefinder/license_finder

RUN apt-get -y update && apt-get install -y jq
COPY build.sh .
COPY BP-BASE-SHELL-STEPS/functions.sh .
COPY BP-BASE-SHELL-STEPS/log-functions.sh .

COPY default_dependency_decisions.yml /tmp/dependency_decisions.yml

ENV ACTIVITY_SUB_TASK_CODE BP-LICENSE_FINDER
ENV SLEEP_DURATION 5s
ENV VALIDATION_FAILURE_ACTION WARNING
ENTRYPOINT [ "./build.sh" ]
