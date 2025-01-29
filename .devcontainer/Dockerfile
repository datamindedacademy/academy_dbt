FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm
ARG USERNAME=gitpod
ARG USER_UID=1234
ARG USER_GID=$USER_UID

# This env var is used to force the 
# rebuild of the Gitpod environment when needed
ENV TRIGGER_REBUILD 0

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER gitpod

RUN pip install "dbt-core==1.9.1" "dbt-snowflake==1.9.0" --no-warn-script-location

# Create empty .dbt directory otherwise dbt complains
RUN mkdir /home/gitpod/.dbt
