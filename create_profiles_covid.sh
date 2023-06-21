#!/bin/bash  
  
# Read the user input     
echo "Enter the username. The user name is your <firstname>"
read user  
schema=$user
echo $user $schema

# Read the password, do not display it and display stars instead 
unset $password
prompt="Enter the password:"
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
        printf "\n"
        break
    fi
    prompt='*'
    password+="$char"
done
# End reading password

mkdir /home/gitpod/.dbt/
echo "covid:
  outputs:
    dev:
      account: yw41113.eu-west-1
      database: academy_dbt
      password: $password
      role: student
      schema: $schema
      threads: 1
      type: snowflake
      user: $user
      warehouse: COMPUTE_WH
  target: dev" > /home/gitpod/.dbt/profiles.yml

