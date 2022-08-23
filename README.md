# NobleProg Terraform for Managing Cloud Infrastructure by HF Silva

This is a demo of what we have done during the day 1 of the course including

- Basic configuration
- Best practices
- Set versions to providers
- Create modules
- Templating
- Variables/local variables
- Terraform state
- Providers
- Write/preview/create/destroy infrastructure
- Work with multiple providers

## Instructions

Run

```
# Go to the folder `TerraformDay1` or `TerraformDay2`and run
terraform init
terraform plan

# To create the infrastructure
terraform apply

# To delete the infrastructure
terraform destroy

For `TerraformDay2`
Generate ssh keys andd add them into the `/nodes/files` folder with the name `dev_nodes_key`
and create a `docker-compose.yaml` file with a valid docker-compose configuration

```
