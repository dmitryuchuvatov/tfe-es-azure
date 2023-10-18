# Terraform Enterprise installation in External Services mode on Azure

# Prerequisites
* Install and configure Terraform as per [official documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

* Azure account

* TFE license file in **.rli** format

# How To

## Clone repository

```
git clone https://github.com/dmitryuchuvatov/tfe-es-azure.git
```

## Change folder

```
cd tfe-es-azure
```

## Authenticate to Azure

Run the command below without any parameters and follow the instructions to sign in to Azure.

```
az login
```

Alternatively, utilize [this document](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/azure_cli) to authenticate


## Terraform init

```
terraform init
```

## Terraform apply

```
terraform apply
```

When prompted, type **yes** and hit **Enter** to start provisioning Azure infrastructure and installing TFE on it


## Configuring TFE

You should see the similar result:

```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

replicated_dashboard = "https://dmitry-tfe.westeurope.cloudapp.azure.com:8800"
ssh_login = "ssh adminuser@40.68.116.63"
```

Click on the link to start configuring TFE:

![Screenshot 2023-10-18 at 14 53 03](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/0609acae-32f4-483c-88d5-6f09ef3c7e1b)

Copy-paste the FQDN to Hostname field and select Self-Signed option to proceed (or upload the CA-signed certificate and private key)

![Screenshot 2023-10-18 at 14 54 22](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/460f718b-1340-4a4f-8982-8c2fef4ced77)

Upload the license in **.rli** format and then, select **Online** installation type -> **Continue**:

![Screenshot 2023-10-18 at 14 54 42](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/a411b6bc-f0ca-4008-b96a-b136d47b542e)

Specify the password for accessing Replicated console -> **Continue**:

![Screenshot 2023-10-18 at 14 55 37](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/b896197b-670e-437a-b1da-cfa8486646fc)

Wait for Pre-flight check to complete, and click **Continue**:

![Screenshot 2023-10-18 at 14 56 28](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/52b7699b-b682-42af-be94-26bd531a6a46)

You will be redirected to **Settings** tab, where you need to setup an encryption password:

![Screenshot 2023-10-18 at 14 57 20](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/b02f5c25-67b9-40fc-92ef-a4a704b0cf0a)






