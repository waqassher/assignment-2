# Firstly we will create a random generated password which we will use in secrets.

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Now create secret and secret versions for database master account 

resource "aws_secretsmanager_secret" "secretmasterDB" {
  name = "Masteraccoundbwaqas013"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.secretmasterDB.id
  secret_string = <<EOF
   {
    "username": "admin",
    "password": "${random_password.password.result}"
   }
EOF
}

# Lets import the Secrets which got created recently and store it so that we can use later. 


data "aws_secretsmanager_secret" "secretmasterDB" {
  arn = aws_secretsmanager_secret.secretmasterDB.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secretmasterDB.arn
}

# After Importing the secrets Storing the Imported Secrets into Locals

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}
