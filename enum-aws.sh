#!/bin/bash

########################
### FUNCOES GRAFICAS ###
########################

# Cores para melhor visualização
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações padrão
DIR_WORDLIST="wordlists/directories.txt"
FILE_WORDLIST="wordlists/files.txt"
BRUTE_WORDLIST="wordlists/brute.txt"

# Função para verificar se o terminal suporta cores
supports_colors() {
  if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors)" -ge 8 ]; then
    return 0
  else
    return 1
  fi
}

# Textos para Loading
tryConnectTxt="Verificando conexão... %s"

# Banner
show_banner() {
  if supports_colors; then
    echo -e "${YELLOW}"
    echo "============================================"
    echo "  DEV-SERVER ENUMERATOR & BRUTE FORCE TOOL  "
    echo "============================================"
    echo -e "${NC}"
  else
    echo "============================================"
    echo "  DEV-SERVER ENUMERATOR & BRUTE FORCE TOOL  "
    echo "============================================"
  fi
  return 0
}

# Loading
show_loading() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  if supports_colors; then
    while kill -0 "$pid" 2>/dev/null; do
      local temp=${spinstr#?}
      printf "\r${BLUE}${tryConnectTxt}${NC}" "${spinstr:0:1}"
      spinstr=$temp${spinstr%"$temp"}
      sleep "$delay"
    done
    printf "\r${GREEN}Conexão verificada!         ${NC}\n"
  else
    while kill -0 "$pid" 2>/dev/null; do
      local temp=${spinstr#?}
      printf "\r${tryConnectTxt}" "${spinstr:0:1}"
      spinstr=$temp${spinstr%"$temp"}
      sleep "$delay"
    done
    printf "\rConexão verificada! \n"
  fi
  return 0
}

############################
### CHECAGEM E VALIDACAO ###
############################

# Verifica o retorno das outras funções
check_return() {
  local exit_code=$?
  local caller_function="${FUNCNAME[1]}"
  local message="${1:-"Erro na execução da função $caller_function"}"

  if [ $exit_code -ne 0 ]; then
    if supports_colors; then
      echo -e "${RED}[ERRO] $message (Código: $exit_code)${NC}" >&2
    else
      echo "[ERRO] $message (Código: $exit_code)" >&2
    fi
    return $exit_code
  fi
  return 0
}

check_status() {
  local url="$1"
  if [ -z "$url" ]; then
    if supports_colors; then
      echo -e "${YELLOW}Erro: URL não fornecida para check_status.${NC}" >&2
    else
      echo "Erro: URL não fornecida para check_status." >&2
    fi
    return 1
  fi
  # Inicia a requisição em segundo plano
  curl -s -o /dev/null -w "%{http_code}" "$url" > .http_status &
  local curl_pid=$!

  # Mostra a animação de loading enquanto a requisição está em andamento
  show_loading $curl_pid
  check_return "Falha ao exibir animação de loading"

  # Aguarda a conclusão do curl e obtém o código HTTP
  wait $curl_pid
  local curl_exit_status=$?
  http_code=$(cat .http_status 2>/dev/null || echo "0")
  rm -f .http_status 2>/dev/null

  if [ $curl_exit_status -ne 0 ] || [ "$http_code" -ne 200 ]; then
    if supports_colors; then
      echo -e "${YELLOW}Erro: Não foi possível acessar a página (código HTTP: $http_code, status curl: $curl_exit_status).${NC}" >&2
    else
      echo "Erro: Não foi possível acessar a página (código HTTP: $http_code, status curl: $curl_exit_status)." >&2
    fi
    return 1
  fi
  return 0
}

# Raspagem de informações
scrape_inputs() {
  local url="$1"
  if [ -z "$url" ]; then
    if supports_colors; then
      echo -e "${YELLOW}Erro: URL não fornecida para scrape_inputs.${NC}" >&2
    else
      echo "Erro: URL não fornecida para scrape_inputs." >&2
    fi
    return 1
  fi
  if supports_colors; then
    echo -e "${BLUE}Baixando página...${NC}"
  else
    echo "Baixando página..."
  fi
  # Faz a requisição e extrai as tags <input>
  local inputs
  inputs=$(curl -s -H "User-Agent: Mozilla/5.0" "$url" | grep -oP '<input[^>]*>')
  if [ -z "$inputs" ]; then
    if supports_colors; then
      echo -e "${YELLOW}Nenhum campo <input> encontrado na página.${NC}"
    else
      echo "Nenhum campo <input> encontrado na página."
    fi
    return 1
  fi
  echo "$inputs" | while IFS= read -r line; do
    # Extrai atributos comuns (type, name, id, value, etc.)
    type=$(echo "$line" | grep -oP 'type="\K[^"]*')
    name=$(echo "$line" | grep -oP 'name="\K[^"]*')
    id=$(echo "$line" | grep -oP 'id="\K[^"]*')
    value=$(echo "$line" | grep -oP 'value="\K[^"]*')
    placeholder=$(echo "$line" | grep -oP 'placeholder="\K[^"]*')

    # Exibe apenas se houver atributos relevantes
    if [ -n "$type" ] || [ -n "$name" ] || [ -n "$id" ]; then
      if supports_colors; then
        echo -e "${BLUE}Campo <input> encontrado:${NC}"
      else
        echo "Campo <input> encontrado:"
      fi
      [ -n "$type" ] && echo "  Tipo: $type"
      [ -n "$name" ] && echo "  Nome: $name"
      [ -n "$id" ] && echo "  ID: $id"
      [ -n "$value" ] && echo "  Valor padrão: $value"
      [ -n "$placeholder" ] && echo "  Placeholder: $placeholder"
      echo "  Tag completa: $line"
      echo ""
    fi
  done
  check_return "Falha ao processar campos <input>"
}

####################
### FUNCOES CORE ###
####################

# Iniciar o script
main() {
  show_banner
  check_return "Falha ao exibir o banner"
  # Primeira pergunta + leitura da resposta
  if supports_colors; then
    echo -e "${BLUE} [*]${NC} URL do site:"
  else
    echo " [*] URL do site:"
  fi
  read -p "> " URL
  if [ -z "$URL" ]; then
    if supports_colors; then
      echo -e "${YELLOW}Erro: URL não fornecida.${NC}" >&2
    else
      echo "Erro: URL não fornecida." >&2
    fi
    return 1
  fi
  # Passa a variável para função check_status
  check_status "$URL"
  check_return "Falha ao verificar o status da conexão"
  if supports_colors; then
    echo -e "${BLUE}Procurando campos <input> na página $URL...${NC}"
  else
    echo "Procurando campos <input> na página $URL..."
  fi
  scrape_inputs "$URL"
  check_return "Falha ao realizar scraping de campos <input>"
}

# Executa a função principal
main