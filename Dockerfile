FROM licensefinder/license_finder


RUN curl -L -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x /usr/local/bin/jq

RUN groupadd -g 65522 buildpiper && \
    useradd -u 65522 -g buildpiper -m -d /home/buildpiper buildpiper

RUN mkdir -p /home/buildpiper/reports \
             /bp/data \
             /bp/execution_dir \
             /opt/buildpiper/shell-functions \
             /bp/workspace && \
    chown -R buildpiper:buildpiper /home/buildpiper /bp /opt

COPY --chown=buildpiper:buildpiper build.sh /home/buildpiper/build.sh
COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS/functions.sh /opt/buildpiper/shell-functions/

COPY default_dependency_decisions.yml /tmp/dependency_decisions.yml

RUN chmod +x /home/buildpiper/build.sh

ENV ACTIVITY_SUB_TASK_CODE=BP-LICENSE_FINDER
ENV SLEEP_DURATION=5s
ENV VALIDATION_FAILURE_ACTION=WARNING

USER buildpiper
WORKDIR /home/buildpiper

ENTRYPOINT ["./build.sh"]
