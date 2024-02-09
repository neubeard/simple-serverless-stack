#!/bin/bash

## Setup serverless stack on AWS account using terraform 
##

if [ $# -ne 1 ] 
then
  echo -e "\n\nUSAGE: ./deploy.sh CREATE/DELETE\n pass atleast one param CREATE --> to create or DELETE to delete"
else
  CASE=$1
fi



create_infra () {
  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
  else
    exit 1
  fi
}


delete_infra () {
  cd ../terraform
  terraform plan -destroy -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -destroy -auto-approve tfplan
  else
    exit 1
  fi
}


if [ "$CASE" == "CREATE" ]
then
  create_infra
elif [ "$CASE" == "DELETE" ]
then
  delete_infra
fi
