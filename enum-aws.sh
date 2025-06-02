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

# Verifica e carrega wordlist
load_wordlist() {
    local path=$1
    local default_items=("$2")
    
    if [ -f "$path" ]; then
        echo "$path"
    else
        echo -e "${YELLOW}[!] Wordlist não encontrada em $path, usando lista mínima padrão${NC}" >&2
        # Criar arquivo temporário com itens padrão
        temp_file=$(mktemp)
        printf "%s\n" "${default_items[@]}" > "$temp_file"
        echo "$temp_file"
    fi
}

# Função para enumerar diretórios
enumerate_directories() {
    local base_url=$1
    local wordlist=$2
    
    echo -e "\n${YELLOW}[+] Enumerando diretórios...${NC}"
    echo -e "${GREEN}[*] Usando wordlist: $wordlist${NC}\n"
    
    total=$(wc -l < "$wordlist")
    count=0
    
    while IFS= read -r dir; do
        ((count++))
        # Remover quebras de linha e espaços
        dir=$(tr -d '\r\n' <<< "$dir" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$dir" ] && continue
        
        # Garantir que o diretório termine com /
        [[ "$dir" != */ ]] && dir="${dir}/"
        
        url="${base_url}${dir}"
        printf "\r${YELLOW}Testando (%d/%d): %s${NC}" "$count" "$total" "$url"
        
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        
        if [ "$response" == "200" ]; then
            echo -e "\n${GREEN}[+] Diretório encontrado (${response}): $url${NC}"
        elif [[ "$response" =~ ^(403|401)$ ]]; then
            echo -e "\n${YELLOW}[!] Acesso não autorizado (${response}): $url${NC}"
        fi
    done < "$wordlist"
    
    echo -e "\n${GREEN}[*] Enumeração de diretórios concluída!${NC}"
}

# Função para enumerar arquivos
enumerate_files() {
    local base_url=$1
    local wordlist=$2
    
    echo -e "\n${YELLOW}[+] Enumerando arquivos...${NC}"
    echo -e "${GREEN}[*] Usando wordlist: $wordlist${NC}\n"
    
    total=$(wc -l < "$wordlist")
    count=0
    
    while IFS= read -r file; do
        ((count++))
        # Remover quebras de linha e espaços
        file=$(tr -d '\r\n' <<< "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$file" ] && continue
        
        url="${base_url}${file}"
        printf "\r${YELLOW}Testando (%d/%d): %s${NC}" "$count" "$total" "$url"
        
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        
        if [ "$response" == "200" ]; then
            echo -e "\n${GREEN}[+] Arquivo encontrado (${response}): $url${NC}"
            # Mostrar conteúdo se for um arquivo (apenas as primeiras linhas)
            echo -e "Conteúdo (primeiras linhas):"
            curl -s "$url" | head -n 5
            echo -e "\n----------------------------------------"
        elif [[ "$response" =~ ^(403|401)$ ]]; then
            echo -e "\n${YELLOW}[!] Acesso não autorizado (${response}): $url${NC}"
        fi
    done < "$wordlist"
    
    echo -e "\n${GREEN}[*] Enumeração de arquivos concluída!${NC}"
}

# Função para brute force
brute_force() {
    local base_url=$1
    local target=$2
    local wordlist=$3
    
    echo -e "\n${YELLOW}[+] Iniciando brute force em $target...${NC}"
    echo -e "${GREEN}[*] Usando wordlist: $wordlist${NC}\n"
    
    total=$(wc -l < "$wordlist")
    count=0
    
    while IFS= read -r line; do
        ((count++))
        # Remover quebras de linha e espaços
        line=$(tr -d '\r\n' <<< "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$line" ] && continue
        
        url="${base_url}${target}${line}"
        printf "\r${YELLOW}Testando (%d/%d): %s${NC}" "$count" "$total" "$url"
        
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        
        if [ "$response" == "200" ]; then
            echo -e "\n${GREEN}[+] Encontrado (${response}): $url${NC}"
        elif [[ "$response" =~ ^(403|401)$ ]]; then
            echo -e "\n${YELLOW}[!] Acesso não autorizado (${response}): $url${NC}"
        fi
    done < "$wordlist"
    
    echo -e "\n${GREEN}[*] Brute force concluído!${NC}"
}

# Menu de enumeração
enumeration_menu() {
    local base_url=$1
    
    # Carregar wordlists
    dir_wordlist=$(load_wordlist "$DIR_WORDLIST" "admin/")
    file_wordlist=$(load_wordlist "$FILE_WORDLIST" "index.html")
    
    while true; do
        echo -e "\n${YELLOW}Menu de Enumeração:${NC}"
        echo "1. Enumerar diretórios (usando $DIR_WORDLIST)"
        echo "2. Enumerar arquivos (usando $FILE_WORDLIST)"
        echo "3. Enumerar diretórios e arquivos"
        echo "4. Definir novo caminho para wordlists"
        echo "5. Voltar ao menu principal"
        
        read -r -p "Escolha uma opção: " option
        
        case $option in
            1)
                enumerate_directories "$base_url" "$dir_wordlist"
                ;;
            2)
                enumerate_files "$base_url" "$file_wordlist"
                ;;
            3)
                enumerate_directories "$base_url" "$dir_wordlist"
                enumerate_files "$base_url" "$file_wordlist"
                ;;
            4)
                echo -e "\nDigite o caminho para a wordlist de diretórios (atual: $DIR_WORDLIST):"
                read -r new_dir_list
                [ -n "$new_dir_list" ] && DIR_WORDLIST="$new_dir_list"
                
                echo -e "\nDigite o caminho para a wordlist de arquivos (atual: $FILE_WORDLIST):"
                read -r new_file_list
                [ -n "$new_file_list" ] && FILE_WORDLIST="$new_file_list"
                
                # Recarregar wordlists
                dir_wordlist=$(load_wordlist "$DIR_WORDLIST" "admin/")
                file_wordlist=$(load_wordlist "$FILE_WORDLIST" "index.html")
                ;;
            5)
                [ -f "$dir_wordlist" ] && [[ "$dir_wordlist" == /tmp/* ]] && rm "$dir_wordlist"
                [ -f "$file_wordlist" ] && [[ "$file_wordlist" == /tmp/* ]] && rm "$file_wordlist"
                break
                ;;
            *)
                echo -e "\n${RED}[-] Opção inválida!${NC}"
                ;;
        esac
    done
}

# Menu principal
main() {
    show_banner
    
    echo -e "\nInforme a URL alvo (ex: http://3.131.157.209/):"
    read -r base_url
    
    # Garantir que a URL termine com /
    [[ "$base_url" != */ ]] && base_url="${base_url}/"
    
    echo -e "\nInforme o parâmetro para brute force (ex: '?page=' ou 'admin/'):"
    read -r target
    
    # Carregar wordlist para brute force
    brute_wordlist=$(load_wordlist "$BRUTE_WORDLIST" "admin")
    
    while true; do
        echo -e "\n${YELLOW}Menu Principal:${NC}"
        echo "1. Menu de Enumeração"
        echo "2. Realizar brute force (usando $BRUTE_WORDLIST)"
        echo "3. Definir novo caminho para wordlist de brute force"
        echo "4. Sair"
        
        read -r -p "Escolha uma opção: " option
        
        case $option in
            1)
                enumeration_menu "$base_url"
                ;;
            2)
                brute_force "$base_url" "$target" "$brute_wordlist"
                ;;
            3)
                echo -e "\nDigite o caminho para a wordlist de brute force (atual: $BRUTE_WORDLIST):"
                read -r new_brute_list
                [ -n "$new_brute_list" ] && BRUTE_WORDLIST="$new_brute_list"
                brute_wordlist=$(load_wordlist "$BRUTE_WORDLIST" "admin")
                ;;
            4)
                [ -f "$brute_wordlist" ] && [[ "$brute_wordlist" == /tmp/* ]] && rm "$brute_wordlist"
                echo -e "\n${YELLOW}[*] Saindo...${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}[-] Opção inválida!${NC}"
                ;;
        esac
    done
}

# Iniciar o script
main