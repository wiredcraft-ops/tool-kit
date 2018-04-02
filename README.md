## wcl.sh

Generate templates, ssl files and ssh key for new project.

> Template files is still on working.


### How it works

1. Clone this repo to get templates
2. Create ssh key using `ssh-keygen`
3. Create ssl files using `opsnssl`

### Usage

```bash
# Clone code from 'shell' branch
$ git clone -b shell git@github.com:wiredcraft-ops/tool-kit.git
```

```bash
$ ./wcl.sh new hello

$ ls hello/

├── ansible/
│   ├── build/
│   │   ├── files -> ../files//
│   │   ├── abort.yml
│   │   ├── roles -> ../roles/
│   │   └── templetes -> ../templetes/
│   ├── deploy/
│   │   ├── files -> ../files//
│   │   ├── abort.yml
│   │   ├── roles -> ../roles/
│   │   └── templetes -> ../templetes/
│   ├── files/
│   │   ├── common/
│   │   │   └── ssh/
│   │   │       ├── id_rsa
│   │   │       └── id_rsa.pub
│   │   └── ssl/
│   │       ├── openssl.cnf
│   │       ├── rootCA.key
│   │       ├── rootCA.pem
│   │       ├── rootCA.srl
│   │       ├── san.crt
│   │       ├── san.csr
│   │       ├── san.key
│   │       ├── san.key.nopass
│   │       ├── san.pem
│   │       └── san.pfx
│   ├── host_vars/
│   │   └── dev-all-in-one
│   ├── setup/
│   │   ├── files -> ../files//
│   │   ├── abort.yml
│   │   ├── roles -> ../roles/
│   │   └── templetes -> ../templetes/
│   ├── ansible.cfg
│   ├── build.yml
│   ├── deploy.yml
│   ├── inventory.dev
│   ├── inventory.prod
│   ├── inventory.staging
│   ├── requirements.yml
│   ├── setup.yml
│   └── update_devops.yml
├── pipelines/
│   ├── 99_update_devops.yml
│   └── README.md
└── README.md
```
