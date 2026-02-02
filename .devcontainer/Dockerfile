FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm
ARG USERNAME=vscode

USER $USERNAME

# Install dbt
RUN pip install "dbt-core==1.10.17" "dbt-postgres==1.10.0" "dbt-snowflake==1.10.6" --no-warn-script-location

# Create empty .dbt directory, otherwise dbt complains
RUN mkdir /home/$USERNAME/.dbt
