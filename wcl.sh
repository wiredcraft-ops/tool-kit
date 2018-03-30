#!/bin/bash
#set -eu -o pipefail

get_template_repo(){
    name=$1
    if [[ -z "$name" ]]
    then
        echo "Miss parameters when called 'get_template_repo'"
        exit 0
    fi

    tmp_dir=/tmp/wcl-tool-kit-$(random_pass 4)
    git clone -q -b shell git@github.com:wiredcraft-ops/tool-kit.git $tmp_dir
    mv $tmp_dir/templates ./$name

    # If $tmp_dir exist, clean it.
    if [ -d "$tmp_dir" ]
    then
        rm -rf $tmp_dir
    fi

}

# Default num 10
random_pass(){
    num=$1
    if [[ -z "$num" ]]
    then
        num=10
    fi

    openssl rand -hex $num
}

gen_ssl(){
    name=$1
    if [[ -z "$name" ]]
    then
        echo "Miss parameters when called 'gen_ssl'"
        exit 0
    fi

    current=$(pwd)
    password=$(random_pass)

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


    mkdir -p $name/ansible/files/ssl
    cd $name/ansible/files/ssl
    
    cat > openssl.cnf <<-EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = $country
ST = $state
L = $locality
O = $organization
OU = $organizationalunit
CN = $commonname

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $altname

EOF

    openssl genrsa -des3  -passout pass:$password -out rootCA.key 4096
    openssl req -x509 -new -passin pass:$password -nodes -key rootCA.key -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email" -sha256 -days 3650 -out rootCA.pem
    openssl genrsa -des3 -passout pass:$password -out san.key 4096
    openssl req -new -passin pass:$password -out san.csr -key san.key -config openssl.cnf
    openssl x509 -req -passin pass:$password -days 3650 -in san.csr -out san.crt \
        -CA rootCA.pem -CAkey rootCA.key -CAcreateserial  -sha256 \
        -extensions v3_req -extfile openssl.cnf
    openssl x509 -text -noout -in san.crt
    cat san.crt san.key > san.pem
    openssl pkcs12 -passin pass:$password  -passout pass:$password -export -in san.pem -out san.pfx
    openssl rsa  -passin pass:$password -in san.key -out san.key.nopass
    # TODO: Put $password and san.key.nopass into ansible-vault
    #ansible-vault encrypt san.key.nopass
    cd $current
}


gen_sshkey(){
    name=$1
    if [[ -z "$name" ]]
    then
        echo "Miss parameters when called 'gen_sshkey'"
        exit 0
    fi

    mkdir -p $name/ansible/files/common/ssh
    ssh-keygen -f $name/ansible/files/common/ssh/id_rsa -t rsa -q -C "pipelines@$name" -N ''
}


new(){
    echo "Clone templates..."
    get_template_repo $1

    echo "Create ssh key..."
    gen_sshkey $1

    echo "Create files for ssl..."
    gen_ssl $1
}

upgrade(){
    # WIP
    wcl_path=$( cd "$(dirname "$0")" ; pwd -P )/$(basename $0)
}

# Print usage info
usage(){
    echo "CLI for devops"
    echo "Usage: "
    echo "wcl new "
    echo "      'new <repo>' pull project template, create new ssl and ssh key'"
    echo "      'upgrade' upgrade wcl.sh it self"
}

# Main
## Check params num

case $1 in
	"new") new ${@:2};;
    "upgrade") upgrade;;
	*) echo "invalid params"
       echo
       usage ;;
esac

