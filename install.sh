#!/bin/bash

wctl_alias=$(grep 'alias wctl="bash <(curl -s https://raw.githubusercontent.com/wiredcraft-ops/tool-kit/shell/setup.sh)"' ~/.profile |wc -l)

if [ "$wctl_alias" -eq "0" ]; then
   cat >> ~/.profile <<-EOF
alias wctl="bash <(curl -s https://raw.githubusercontent.com/wiredcraft-ops/tool-kit/shell/setup.sh)"
EOF
   echo "Installed wctl in your ~/.profile"
else
    echo "Already installed."
fi
source ~/.profile
