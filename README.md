## wcl.sh

Generate templates, ssl files and ssh key for new project.

> Template files is still on working.


### How it works

1. Clone this repo to get templates
2. Create ssh key using `ssh-keygen`
3. Create ssl files using `opsnssl`


## Install

You just need the `wcl.sh` and run it in `bash`, that's all.

### Usage

```bash
# Clone code from 'shell' branch
$ git clone -b shell git@github.com:wiredcraft-ops/tool-kit.git
```

> You could store the vault password in `./.vault_password`, or it will ask for you input.

```bash
$ ./wcl.sh new hello

$ tree -F --dirsfirst hello/
├── devops/
│   ├── ansible/
│   │   ├── build/
│   │   │   ├── files -> ../files//
│   │   │   ├── roles -> ../roles//
│   │   │   ├── templates -> ../templates//
│   │   │   └── abort.yml
│   │   ├── deploy/
│   │   │   ├── files -> ../files//
│   │   │   ├── roles -> ../roles//
│   │   │   ├── templates -> ../templates//
│   │   │   └── abort.yml
│   │   ├── files/
│   │   │   ├── common/
│   │   │   │   ├── ssh/
│   │   │   │   │   ├── id_rsa
│   │   │   │   │   └── id_rsa.pub
│   │   │   │   └── ssl/
│   │   │   │       └── private/
│   │   │   │           ├── openssl.cnf
│   │   │   │           ├── rootCA.key
│   │   │   │           ├── rootCA.pem
│   │   │   │           ├── rootCA.srl
│   │   │   │           ├── san.crt
│   │   │   │           ├── san.csr
│   │   │   │           ├── san.key
│   │   │   │           ├── san.key.nopass
│   │   │   │           ├── san.pem
│   │   │   │           └── san.pfx
│   │   │   ├── dev/
│   │   │   ├── production/
│   │   │   ├── ssl/
│   │   │   └── staging/
│   │   ├── group_vars/
│   │   │   ├── all/
│   │   │   │   ├── ssl.vault
│   │   │   │   └── vars.yml
│   │   │   ├── all-dev/
│   │   │   │   └── vars.yml
│   │   │   ├── all-production/
│   │   │   │   └── vars.yml
│   │   │   ├── all-staging/
│   │   │   │   └── vars.yml
│   │   │   └── all-tools/
│   │   │       └── vars.yml
│   │   ├── host_vars/
│   │   │   └── dev-all-in-one
│   │   ├── roles/
│   │   ├── setup/
│   │   │   ├── files -> ../files//
│   │   │   ├── roles -> ../roles//
│   │   │   ├── templates -> ../templates//
│   │   │   └── abort.yml
│   │   ├── templates/
│   │   │   ├── dev/
│   │   │   ├── production/
│   │   │   ├── staging/
│   │   │   └── tools/
│   │   ├── ansible.cfg
│   │   ├── build.yml
│   │   ├── deploy.yml
│   │   ├── inventory.dev
│   │   ├── inventory.production
│   │   ├── inventory.staging
│   │   ├── inventory.tools
│   │   ├── requirements.yml
│   │   ├── setup.yml
│   │   ├── update_devops.yml
│   │   ├── vars.dev
│   │   ├── vars.production
│   │   └── vars.staging
│   ├── pipelines/
│   │   ├── 02_build.yml
│   │   ├── 03_deploy.yml
│   │   ├── 99_update_devops.yml
│   │   └── README.md
│   └── README.md
└── README.md
```
