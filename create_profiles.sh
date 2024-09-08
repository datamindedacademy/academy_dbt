#!/bin/bash  
  
# Read the user input     
echo -n "Enter your first name: "
read firstname
user=summerschool2024_$firstname
schema=dbt_$firstname

# Read the password, do not display it and display stars instead 
unset $password
prompt="Enter the Snowflake password: "
while IFS= read -p "$prompt" -r -s -n 1 char
do
  # Enter - accept password
  if [[ $char == $'\0' ]] ; then
    printf "\n"
    break
  fi
  # Backspace
  if [[ $char == $'\177' ]] ; then
    prompt=$'\b \b'
    password="${password%?}"
  else
    prompt='*'
    password+="$char"
  fi
done
# End reading password

echo "Snowflake Username: $user"
echo "Snowflake password: <not shown>"
echo "Snowflake schema: $schema"
read -p "Does this look correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Aborting. Re-run the script to try again."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # exit the script
else
  echo "Writing ~/.dbt/profiles.yml. Re-run the script to set it again."
fi

mkdir -p /home/gitpod/.dbt/
echo "audience_measurement:
  outputs:
    dev:
      account: ic07601.eu-west-1
      database: summerschool2024
      password: $password
      role: student
      schema: $schema
      threads: 1
      type: snowflake
      user: $user
      warehouse: COMPUTE_WH
  target: dev
testproject:
  outputs:
    dev:
      account: ic07601.eu-west-1
      database: summerschool2024
      password: $password
      role: student
      schema: $schema
      threads: 1
      type: snowflake
      user: $user
      warehouse: COMPUTE_WH
  target: dev
covid:
  outputs:
    dev:
      account: ic07601.eu-west-1
      database: summerschool2024
      password: $password
      role: student
      schema: $schema
      threads: 1
      type: snowflake
      user: $user
      warehouse: COMPUTE_WH
  target: dev" > /home/gitpod/.dbt/profiles.yml

