#cloud-config
packages:
- git 
- jq 
- vim 
- language-pack-en
- wget
- curl
- zip
- unzip
- ca-certificates
- gnupg
- lsb-release
write_files:
  - path: "/tmp/install-tfe.sh"
    permissions: "0755"
    owner: "root:root"
    content: |
      #!/bin/bash

      curl -sL https://install.terraform.io/ptfe/stable > /tmp/install.sh
      bash /tmp/install.sh no-proxy private-address=10.200.1.4 public-address=10.200.1.4
  - path: "/tmp/azure-cli.sh"
    permissions: "0755"
    owner: "root:root"
    content: |
      #!/bin/bash

      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      wget https://aka.ms/downloadazcopy-v10-linux
      tar -xvf downloadazcopy-v10-linux
      cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
      chmod 755 /usr/bin/azcopy
runcmd: 
  - sudo apt-get -y update
  - bash /tmp/install-tfe.sh
  - bash /tmp/azure-cli.sh
