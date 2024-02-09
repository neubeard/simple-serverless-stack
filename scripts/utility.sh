#!/bin/bash

## Utility script to create generate error scenarios
##

if [ $# -ne 2 ]
then
  echo -e "\n\nUSAGE: ./utility.sh <SCENARIO-KEYWORD> <API_GATEWAY_URL>\n  e.g. ./utility.sh throttle_api rp95f8wo9f.execute-api.us-east-2.amazonaws.com\n\nAllowed values for SCENARIO-KEYWORD:\n  - throttle_api\n  - wrong_db\n  - throttle_lambda\n  - timeout_lambda\n  - duplicate_id_db_post\n  - max_write_db\n  - wrong_key_db_post\n  - large_item_db_post\n  - batch_write_limit_db\n  - wrong_lib_lambda\n  - batch_read_limit_db\n  - max_read_db"
else
  API_URL=$2
  CASE=$1
fi

SOURCE_JSON_DIR="../scenarios_test"

throttle_lambda () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
EOF

  cd ../terraform
  rm -rf terraform.tfplan
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    seq 1 40 | xargs -I {} -P20  curl "https://$API_URL/items"  > /dev/null
  else
    exit 1
  fi
}

throttle_api () {
 echo "This scenario not working yet"

}

wrong_db () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-misconfig_db.mjs"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl "https://$API_URL/items"
  else
    exit 1
  fi
}

timeout_lambda () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-timeout.mjs"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl "https://$API_URL/items"
  else
    exit 1
  fi
}

duplicate_id_db_post () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
EOF

  cd ../terraform
  rm -rf terraform.tfplan
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl -XPOST -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/duplicate_ids.json)" "https://$API_URL/bulkitems"
  else
    exit 1
  fi
}

wrong_key_db_post () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
EOF

  cd ../terraform
  rm -rf terraform.tfplan
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl -XPOST -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/wrong_key.json)" "https://$API_URL/bulkitems"
  else
    exit 1
  fi
}

large_item_db_post () {
  # Facing issues, needs fixing
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
EOF

  cd ../terraform
  rm -rf terraform.tfplan
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl -XPOST -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/large_item.json)" "https://$API_URL/bulkitems"
  else
    exit 1
  fi
}

batch_write_limit_db () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-batch_limit.mjs"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl -XPOST -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/batch_write_limit.json)" "https://$API_URL/bulkitems"
  else
    exit 1
  fi
}

batch_read_limit_db () {
    ## Need to check some unusual error recieved
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/bulk_read.json)" "https://$API_URL/bulkitems"
  fi
}

wrong_lib_lambda () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-wrong_import.mjs"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl "https://$API_URL/items"
  else
    exit 1
  fi
}

max_write_db () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
  dynamo_write_limits = "1"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    curl -XPOST -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/batch_write_limit.json)" "https://$API_URL/bulkitems"
  else
    exit 1
  fi
}

max_read_db () {
  cat > ../terraform/terraform.tfvars << EOF
  lambda_file = "http-crud-function.mjs"
  dynamo_read_limits = "1"
EOF

  cd ../terraform
  terraform plan -out=tfplan
  echo -e "\n\n\nIF ABOVE TERRAFORM PLAN LOOKS GOOD THEN TYPE yes TO MAKE CHANGES TO THE SERVERLESS STACK\n\nType yes to continue, no to exit(yes/no)default-yes:"
  read ACTION
  if [ "$ACTION" == "" ] || [ "$ACTION" == "yes" ]
  then
    terraform apply -auto-approve tfplan
    for i in 1 2 3
    do
      curl  -H "Content-type: application/json" -d "$(cat $SOURCE_JSON_DIR/bulk_read_limit.json)" "https://$API_URL/bulkitems"
    done
  else
    exit 1
  fi
}

if [ "$CASE" == "throttle_api" ]
then
  throttle_api
elif [ "$CASE" == "throttle_lambda" ]
then
  throttle_lambda
elif [ "$CASE" == "wrong_db" ]
then
  wrong_db
elif [ "$CASE" == "timeout_lambda" ]
then
  timeout_lambda
elif [ "$CASE" == "duplicate_id_db_post" ]
then
  duplicate_id_db_post
elif [ "$CASE" == "wrong_key_db_post" ]
then
  wrong_key_db_post
elif [ "$CASE" == "large_item_db_post" ]
then
  large_item_db_post
elif [ "$CASE" == "batch_write_limit_db" ]
then
  batch_write_limit_db
elif [ "$CASE" == "batch_read_limit_db" ]
then
  batch_read_limit_db
elif [ "$CASE" == "wrong_lib_lambda" ]
then
  wrong_lib_lambda
elif [ "$CASE" == "max_write_db" ]
then
  max_write_db
elif [ "$CASE" == "max_read_db" ]
then
  max_read_db
fi
