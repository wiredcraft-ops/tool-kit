## wctl

Generate templates, ssl files and ssh key for new project.


### How it works

1. Clone this repo to get templates
2. Create ssh key using `ssh-keygen`
3. Create ssl files using `opsnssl`


## Install

### Requirements

- bash
- openssl
- ssh-keygen

```bash
$ curl -fsSL https://raw.githubusercontent.com/wiredcraft-ops/tool-kit/shell/install.sh | bash
$ wctl version
```


## Usage

```bash
$ wctl new test-devops
$ tree -F --dirsfirst
.
└── test-devops/
    └── devops/
        ├── ansible/
        │   ├── build/
        │   │   ├── files -> ../files//
        │   │   ├── roles -> ../roles//
        │   │   ├── templates -> ../templates//
        │   │   └── abort.yml
        │   ├── deploy/
        │   │   ├── files -> ../files//
        │   │   ├── roles -> ../roles//
        │   │   ├── templates -> ../templates//
        │   │   └── abort.yml
        │   ├── files/
        │   │   ├── common/
        │   │   │   ├── ssh/
        │   │   │   │   ├── pipelines_rsa
        │   │   │   │   ├── pipelines_rsa.pub
        │   │   │   │   ├── wcladmin
        │   │   │   │   └── wcladmin.pub
        │   │   │   └── ssl/
        │   │   │       └── private/
        │   │   │           ├── openssl.cnf
        │   │   │           ├── rootCA.key
        │   │   │           ├── rootCA.pem
        │   │   │           ├── rootCA.srl
        │   │   │           ├── san.crt
        │   │   │           ├── san.csr
        │   │   │           ├── san.key
        │   │   │           ├── san.key.nopass
        │   │   │           ├── san.pem
        │   │   │           └── san.pfx
        │   │   ├── dev/
        │   │   ├── production/
        │   │   └── staging/
        │   ├── group_vars/
        │   │   ├── all/
        │   │   │   ├── ssl.vault
        │   │   │   └── vars.yml
        │   │   ├── all-dev/
        │   │   │   └── vars.yml
        │   │   ├── all-production/
        │   │   │   └── vars.yml
        │   │   ├── all-staging/
        │   │   │   └── vars.yml
        │   │   └── all-tools/
        │   │       └── vars.yml
        │   ├── host_vars/
        │   │   └── dev-all-in-one
        │   ├── roles/
        │   ├── setup/
        │   │   ├── files -> ../files//
        │   │   ├── roles -> ../roles//
        │   │   ├── templates -> ../templates//
        │   │   └── abort.yml
        │   ├── templates/
        │   │   ├── dev/
        │   │   ├── production/
        │   │   ├── staging/
        │   │   └── tools/
        │   ├── ansible.cfg
        │   ├── build.yml
        │   ├── deploy.yml
        │   ├── inventory.dev
        │   ├── inventory.production
        │   ├── inventory.staging
        │   ├── inventory.tools
        │   ├── requirements.yml
        │   ├── setup.yml
        │   ├── update_devops.yml
        │   ├── vars.dev
        │   ├── vars.production
        │   └── vars.staging
        └── pipelines/
            ├── 02_build.yml
            ├── 03_deploy.yml
            └── 99_update_devops.yml
```
