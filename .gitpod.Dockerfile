FROM gitpod/workspace-full:2023-05-02-12-55-13

# This env var is used to force the 
# rebuild of the Gitpod environment when needed
ENV TRIGGER_REBUILD 0

USER root

RUN apt-get update && \
    apt-get install -y wget git tree ssh nano sudo nmap man tmux curl joe && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    pip install "dbt-core==1.7.7" "dbt-snowflake==1.7.1"

# Copy exercices content into the image
# COPY --chown=gitpod content/ /home/gitpod/dbt_audiance_measurment

USER gitpod

# Create empty .dbt directory otherwise dbt complains
RUN mkdir /home/gitpod/.dbt
