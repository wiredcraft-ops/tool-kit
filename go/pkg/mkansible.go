package pkg

import (
	"errors"
	"path"
)

var (
	ansiblecfg = `[ssh_connection]
ssh_args=-o ForwardAgent=yes

[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = ~/.ansible/cachedir
fact_caching_timeout = 86400
host_key_checking = False
retry_files_enabled = False
`
	setupyml = `---
- import_playbook: setup/{{ component | default('abort') }}.yml
`

	buildyml = `---
- import_playbook: build/{{ component | default('abort') }}.yml
`

	deployyml = `---
- import_playbook: deploy/{{ component | default('abort') }}.yml
`

	abortyml = `---
- hosts: localhost
  connection: local
  tasks:
	- name: Define the component to run
	  debug:
		msg: You need to set the component to run with -e 'component=component'

	- name: Aborting
	  fail:
		msg: component variable is not defined
`
)

func Mkansible(p string) (err error) {

	b, err := IsDir(p)
	if err != nil {
		return err
	}
	if !b {
		return errors.New(p + " is not a directory")
	}

	files := []string{"inventory", "requirements.yml"}
	filesWithContent := map[string]string{
		"ansible.cfg": ansiblecfg,
		"setup.yml":   setupyml,
		"build.yml":   buildyml,
		"deploy.yml":  deployyml,
		"abort.yml":   abortyml,
	}
	dirs := []string{"files", "templates", "roles", "group_vars/all", "host_vars", "setup", "build", "deploy"}
	// newname: oldname
	links := map[string]string{
		"setup/files":      "../files",
		"setup/templates":  "../templates",
		"setup/roles":      "../roles",
		"build/files":      "../files",
		"build/templates":  "../templates",
		"build/roles":      "../roles",
		"deploy/files":     "../files",
		"deploy/templates": "../templates",
		"deploy/roles":     "../roles",
	}

	for _, f := range files {
		err = CreateFile(path.Join(p, f))
		if err != nil {
			return err
		}
	}

	for name, content := range filesWithContent {
		err = CreateFileWithContent(path.Join(p, name), content)
		if err != nil {
			return err
		}
	}

	for _, d := range dirs {
		err = CreateDir(path.Join(p, d))
		if err != nil {
			return err
		}
	}

	for newname, oldname := range links {
		err = CreateSoftLink(oldname, path.Join(p, newname))
		if err != nil {
			return err
		}
	}

	return nil
}
