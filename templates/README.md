# DevOps

Relying on **Ansible** for orchestration and **Pipelines** for automation.


## Ansible

### Requirements

- Ansible >= 2.3.1.0
- Git

### Setup

#### Install ansible roles

```bash
$ ansible-galaxy install -r requirements.yml -p roles
```

#### Run your playbook

In general, all playbooks are in those folders:

- `setup/`: setup all environments, such as node, redis, nginx. (`setup.yml`)
- `build/`: get code and build it, such as `npm install`. (`build.yml`)
- `deploy/`: deploy code or content. (`deploy.yml`)

```bash
$ inv="inventory.dev"
$ component="example"
$ entrypoint="setup.yml"
$ ansible-playbook -i ${inv} ${entrypoint} -e component=${component} -u root --ask-vault-pass
```
