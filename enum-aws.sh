#!/bin/bash

# Cores para melhor visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações padrão
DIR_WORDLIST="wordlists/directories.txt"
FILE_WORDLIST="wordlists/files.txt"
BRUTE_WORDLIST="wordlists/brute.txt"

# Banner
show_banner() {
    echo -e "${YELLOW}"
    echo "============================================"
    echo "  DEV-SERVER ENUMERATOR & BRUTE FORCE TOOL  "
    echo "============================================"
    echo -e "${NC}"
}



# Iniciar o script
main