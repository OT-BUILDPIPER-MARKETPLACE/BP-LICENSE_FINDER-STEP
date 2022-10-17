FROM licensefinder/license_finder

COPY build.sh .
COPY BP-BASE-SHELL-STEPS/functions.sh .
COPY default_dependency_decisions.yml /tmp/dependency_decisions.yml

ENV ACTIVITY_SUB_TASK_CODE BP-LICENSE_FINDER

ENTRYPOINT [ "./build.sh" ]