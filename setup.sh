#!/bin/bash
#set -eu -o pipefail

version="0.0.2"
ssl_password=""
valut_encrypt_password=""

get_template_repo(){
    name=$1
    if [[ -z "${name}" ]]
    then
        echo "Miss parameters when called 'get_template_repo'"
        exit 1
    fi

    tmp_dir=$(mktemp -d)
    git clone -q -b shell git@github.com:wiredcraft-ops/tool-kit.git ${tmp_dir}
    mv ${tmp_dir}/templates ./${name}

    read -p "Hostname in inventory(CHANGEME): " inv_hostname
    inv_hostname=${inv_hostname:-CHANGEME}

    replace_templates ${name}'/devops/ansible/inventory.*' "CHANGEME" "${inv_hostname}"
    replace_templates ${name} "_CHANGEME_NAME_PATH_" "\/opt\/${name}"
    replace_templates ${name} "_CHANGEME_ONLY_NAME_" "${name}"
    replace_templates ${name} "_CHANGEME_REPO_" "git@github.com:Wiredcraft\/${name}.git"
}

replace_templates(){
    local name=$1
    local origin=$2
    local target=$3
    local sed_string='s/'${origin}'/'${target}'/g'
    for f in $(grep -r ${origin} ./${name} -l)
    do
        sed -i '' -e ${sed_string} $f
    done
}

# Default num 10
random_pass(){
    num=$1
    if [[ -z "${num}" ]]
    then
        num=10
    fi

    openssl rand -hex ${num}
}

gen_ssl(){
    name=$1
    if [[ -z "${name}" ]]
    then
        echo "Miss parameters when called 'gen_ssl'"
        exit 1
    fi

    current=$(pwd)
    password=$(random_pass)
    ssl_path=${name}/devops/ansible/files/common/ssl/private
    ssl_vault_path=${name}/devops/ansible/group_vars/all

    # Read vars from stdin
    read -p "Country(CN): " country
    country=${country:-CN}
    read -p "State(Shanghai): " state
    state=${state:-Shanghai}
    read -p "Locality(Shanghai): " locality
    locality=${locality:-Shanghai}
    read -p "organization(Wiredcraft): " organization
    organization=${organization:-Wiredcraft}
    read -p "organizationalunit(Ops): " organizationalunit
    organizationalunit=${organizationalunit:-Ops}
    read -p "commonname(primary.domain.example): " commonname
    commonname=${commonname:-primary.domain.example}
    read -p "altname(alt1.domain.example): " altname
    altname=${altname:-alt1.domain.example}
    read -p "email(example@example): " email
    email=${email:-example@example}


    mkdir -p ${ssl_path}
    cd ${ssl_path}
    
    cat > openssl.cnf <<-EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = ${country}
ST = ${state}
L = ${locality}
O = ${organization}
OU = ${organizationalunit}
CN = ${commonname}

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${altname}

EOF

    openssl genrsa -des3  -passout pass:${password} -out rootCA.key 4096
    openssl req -x509 -new -passin pass:${password} -nodes -key rootCA.key -subj "/C=${country}/ST=${state}/L=${locality}/O=${organization}/OU=${organizationalunit}/CN=${commonname}/emailAddress=$email" -sha256 -days 3650 -out rootCA.pem
    openssl genrsa -des3 -passout pass:${password} -out san.key 4096
    openssl req -new -passin pass:${password} -out san.csr -key san.key -config openssl.cnf
    openssl x509 -req -passin pass:${password} -days 3650 -in san.csr -out san.crt \
        -CA rootCA.pem -CAkey rootCA.key -CAcreateserial  -sha256 \
        -extensions v3_req -extfile openssl.cnf
    openssl x509 -text -noout -in san.crt
    cat san.crt san.key > san.pem
    openssl pkcs12 -passin pass:${password}  -passout pass:${password} -export -in san.pem -out san.pfx
    openssl rsa  -passin pass:${password} -in san.key -out san.key.nopass
    cd ${current}

    # If no password file, ask from stdin
    read -p "vault_password(generate random if empty): " vault_password
    vault_password=${vault_password:-$(random_pass 10)}

    vault_password_file="/tmp/.vault_password"
    echo $vault_password > ${vault_password_file}

    echo "encrypt san.key.nopass..."
    ansible-vault encrypt --vault-password-file=${vault_password_file} ${ssl_path}/san.key.nopass


    echo "encrypt openssl password..."
    echo "vault_ssl_password: "${passowrd} > ${ssl_vault_path}/ssl.vault
    ansible-vault encrypt --vault-password-file=${vault_password_file}  ${ssl_vault_path}/ssl.vault
    ssl_password=${password}
    valut_encrypt_password=${vault_password}
}


gen_sshkey(){
    name=$1
    if [[ -z "${name}" ]]
    then
        echo "Miss parameters when called 'gen_sshkey'"
        exit 1
    fi
    ssh_path=${name}/devops/ansible/files/common/ssh
    mkdir -p ${ssh_path}
    ssh-keygen -f ${ssh_path}/pipelines_rsa -t rsa  -b 4096 -q -C "pipelines@${name}" -N ''
    ssh-keygen -f ${ssh_path}/wcladmin -t rsa  -b 4096 -q -C "wcladmin@${name}" -N ''
}


new(){
    name=$1
    if [[ -z "${name}" ]]
    then
        echo "Miss name('setup.sh new <name>')"
        exit 1
    fi

    echo "Clone templates..."
    get_template_repo ${name}

    echo "Create ssh key..."
    gen_sshkey ${name}

    echo "Create files for ssl..."
    gen_ssl ${name}

    cat <<-EOF


************************************
****** Done ************************

**** Password ****
* SSL Password: ${ssl_password}
* Valut Password: ${valut_encrypt_password}

**** Files ****
* ssh key:
${name}/devops/ansible/files/common/ssh/

* ssl files:
${name}/devops/ansible/files/common/ssl/private/
${name}/devops/ansible/group_vars/all/ssl.valut


************************************
Now you should change some vars for your project.
************************************

Use grep to find them:

$ grep -r CHANGEME test-devops/

(Maybe you also need to check the path in pipelines, they have
already been replaced by 'sed')

$ grep -r path:  test-devops/devops/pipelines/
$ grep -r base_repo:  test-devops/devops/ansible/update_devops.yml

EOF
}

version(){
    echo $version
}

# Print usage info
usage(){
    echo "CLI for devops"
    echo "Usage: "
    echo "wcl new "
    echo "      'new <repo>' pull project template, create new ssl and ssh key'"
    echo "      'version' print version info"
}

# Main
## Check params num

case $1 in
    "new") new ${@:2};;
    "version") version;;
    *) echo "invalid params"
       echo
       usage ;;
esac

