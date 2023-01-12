FROM gitpod/workspace-full:latest-2022-01-21-dazzle-v1

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
    pip install dbt-snowflake && \
    pip install sqlfluff-templater-dbt

# Copy exercices content into the image
# COPY --chown=gitpod content/ /home/gitpod/dbt_audiance_measurment

USER gitpod