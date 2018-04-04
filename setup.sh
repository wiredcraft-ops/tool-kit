#!/bin/bash
#set -eu -o pipefail

version="0.0.1"
ssl_password=""

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

    replace_templates ${name} "_CHANGEME_NAME_PATH_" "\/opt\/${name}"
    replace_templates ${name} "_CHANGEME_ONLY_NAME_" "${name}"
    replace_templates ${name} "_CHANGEME_REPO_" "git@github.com:Wiredcraft\/${name}.git"
}

replace_templates(){
    name=$1
    origin=$2
    target=$3
    sed_string='s/'${origin}'/'${target}'/g'
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
    vault_password_file=""
    if [ -f ".vault_password" ]
    then
        vault_password_file="--vault-password-file=.vault_password"
    fi

    echo "encrypt san.key.nopass..."
    ansible-vault encrypt ${vault_password_file} ${ssl_path}/san.key.nopass


    echo "encrypt openssl password..."
    echo "vault_ssl_password: "${passowrd} > ${ssl_vault_path}/ssl.vault
    ansible-vault encrypt ${vault_password_file}  ${ssl_vault_path}/ssl.vault
    ssl_password=${password}
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
    ssh-keygen -f ${ssh_path}/id_rsa -t rsa  -b 4096 -q -C "pipelines@${name}" -N ''
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
*************
***  Done ***

* SSL Password: ${ssl_password}
EOF
}

upgrade(){
    # WIP
    wcl_path=$( cd "$(dirname "$0")" ; pwd -P )/$(basename $0)
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
    #echo "      'upgrade' upgrade wcl.sh it self"
    echo "      'version' print version info"
}

# Main
## Check params num

case $1 in
    "new") new ${@:2};;
    "upgrade") upgrade;;
    "version") version;;
    *) echo "invalid params"
       echo
       usage ;;
esac

