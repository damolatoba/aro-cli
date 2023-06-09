#!/bin/bash

the_env=$1
gcp_auth_file_path=$2
prod="terraform/state/prod"
staging="terraform/state/staging"
test="terraform/state/test"

escaped_prod=${prod//\//\\/}
escaped_staging=${staging//\//\\/}
escaped_test=${test//\//\\/}

# function to check required inputs and initiate the other functions
initiate_and_check_inputs() {
    if [ -z "$the_env" ] && [ -z "$gcp_auth_file_path" ]; then
        echo "Error: Please supply both the environment and the gcp_auth_file path when running this script."
    else
        delete_dot_tf_dir
        update_backend_in_versions_file
        # tf_init_and_apply
    fi
}

# function to check if .terraform dir and .terraform.lock.hcl file exist and delete
delete_dot_tf_dir() {
    if [ -d ".terraform" ]; then
        echo ".terraform dir exists. Deleting now..."
        rm -rf ".terraform"
        echo ".terraform dir deleted."
    fi

    if [ -f ".terraform.lock.hcl" ]; then
        echo ".terraform.lock.hcl file exists. Deleting now..."
        rm ".terraform.lock.hcl"
        echo ".terraform.lock.hcl file deleted."
    fi
}

# update terraform backend prefix in versions.tf file to point to specified environment tf state
update_backend_in_versions_file() {
    if [[ $the_env == "staging" ]]
    then
        sed -i "" "s/$escaped_test/$escaped_staging/" ./versions.tf
        sed -i "" "s/$escaped_prod/$escaped_staging/" ./versions.tf
        cat versions.tf
    fi

    if [[ $the_env == "test" ]]
    then
        sed -i "" "s/$escaped_staging/$escaped_test/" ./versions.tf
        sed -i "" "s/$escaped_prod/$escaped_test/" ./versions.tf
        cat versions.tf
    fi

    if [[ $the_env == "prod" ]]
    then
        sed -i "" "s/$escaped_test/$escaped_prod/" ./versions.tf
        sed -i "" "s/$escaped_staging/$escaped_prod/" ./versions.tf
        cat versions.tf
    fi
}

# funtion to run terraform init, plan and apply
# tf_init_and_apply() {
#     terraform init
#     terraform apply -var-file=./environments/$the_env.auto.tfvars -var gcp_auth_file=$gcp_auth_file_path
# }

# initiate/run script
initiate_and_check_inputs