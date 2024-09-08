FROM gitpod/workspace-full:2024-09-05-09-30-51

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
    pip install "dbt-core==1.8.6" "dbt-snowflake==1.8.3"

USER gitpod

# Create empty .dbt directory otherwise dbt complains
RUN mkdir /home/gitpod/.dbt
