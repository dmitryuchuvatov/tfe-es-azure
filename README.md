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

Scroll down, select **External Services** and specify the Username, Password, Hostname and Database name.

Username and Password are pre-configured via variables, and Database name is default (**postgres**)

To locate a Hostname, navigate to Azure portal -> Azure Database for PostgreSQL flexible servers -> click on the name of your newly provisioned database -> copy Server name:
![Screenshot 2023-10-18 at 14 59 31](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/3c40e3d0-48ce-4827-8e41-bd97147ceded)

Result: 

![Screenshot 2023-10-18 at 16 09 32](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/565c8ad4-a194-4d19-89d6-edb4a6c9dbe9)


Then, scroll down to Object Storage section, and select Azure:

![Screenshot 2023-10-18 at 16 41 45](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/296705b2-0cf2-4fbf-9143-1fed7439399b)

You will need to specify Storage account name, Storage container, and Storage account key.
Storage account name and Storage container are pre-configured via variables; to obtain a Storage account key navigate to Azure portal -> Storage accounts -> select your storage account name -> Access keys -> click "**Show**" next to **key1** and copy this value:

![Screenshot 2023-10-18 at 15 01 44](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/e96f438f-d48a-475b-821f-12e9b40b1fdd)

Once it done, scroll down to the bottom and click **Save**, followed by **Restart Now**

![Screenshot 2023-10-18 at 15 02 17](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/d439a53b-c2c4-4726-9da9-20f9c071eab3)

Monitor the status of Replicated services in dashboard and ensure that TFE has started.

![Screenshot 2023-10-18 at 15 05 27](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/914a9033-641a-482c-9d60-f98581974bc0)

After that, click on **Open** to set up a user and proceed to create a Workspace:

![Screenshot 2023-10-18 at 15 08 17](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/4a71f11b-589e-4854-a32d-641924336707)

![Screenshot 2023-10-18 at 15 08 31](https://github.com/dmitryuchuvatov/tfe-es-azure/assets/119931089/a86dea39-0215-474a-8f97-c8c79c6872f3)








