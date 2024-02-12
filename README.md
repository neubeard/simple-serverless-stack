# simple-serverless-stack

This repository contains code to deploy simple-serverles stack (api gateway --> lambda --> dynamodb) and to run error scenarios on created stack.

#### Deploy stack
To deploy stack, run below command

```
cd scripts
./deploy.sh create
```

To delete stack, run below command

```
cd /scripts
./deploy.sh delete
```
#### Prerequisites
Make sure you have AWS CLI access enabled using either ~/.aws/credentials file or env variables.

Run write scenarios before read scenarios so that db has data for the read operations.

#### Run various scenarios on the deployed stack
Once the stack is up and running we can run various scenarios on the stack to simulate system and application level errors.
Run script utility.sh to generate specific error scenarios. Based on the SCNENARIO-KEYWORD passed to the script, it takes action needed to generate the scenario.

```
cd scripts/
./utility.sh throttle_api rp95f8wo9f.execute-api.us-east-2.amazonaws.com
./utility.sh (for below help screen)
USAGE: ./utility.sh <SCENARIO-KEYWORD> <API_GATEWAY_URL>
  e.g. ./utility.sh throttle_api rp95f8wo9f.execute-api.us-east-2.amazonaws.com

Allowed values for SCENARIO-KEYWORD:
  - wrong_db
  - throttle_lambda
  - timeout_lambda
  - duplicate_id_db_post
  - max_write_db
  - wrong_key_db_post
  - large_item_db_post
  - batch_write_limit_db
  - wrong_lib_lambda
  - batch_read_limit_db
  - max_read_db

```

Keywords for various scenarios used in the script:

  - *wrong_db*                    --> Use wrong dynamodb name in lambda function causing error
  - *throttle_lambda*             --> Throttle lambda function
  - *timeout_lambda*              --> Simulate lambda function timeout
  - *duplicate_id_db_post*        --> Trying to write same id twice in a batch dynamodb write request
  - *max_write_db*                --> Hit maximum write units on dynamodb
  - *wrong_key_db_post*           --> Calling with wrong primary key causing schema error
  - *large_item_db_post*          --> Hit max individual item limit of 400KB in a batch write request to dynamodb
  - *batch_write_limit_db*        --> Update lambda to call in batch of 26 items to hit 25 items limit  
  - *wrong_lib_lambda*            --> Update lambda with wrong import statement
  - *batch_read_limit_db*         --> Hit maximum read limit on bulk get of 100 items
  - *max_read_db*                 --> Hit maximum read provisioned units on dynamodb
