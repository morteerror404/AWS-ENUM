#!/bin/bash

# Definindo cores para a saída
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# URL da página
URL="http://3.131.157.209/update.html"

# Função para animação de loading
show_loading() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while kill -0 "$pid" 2>/dev/null; do
    local temp=${spinstr#?}
    printf "\r${BLUE}Verificando conexão... %s${NC}" "${spinstr:0:1}"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
  done
  printf "\r${BLUE}Conexão verificada!         ${NC}\n"
}

# Função para verificar se a página está acessível
check_status() {
  # Inicia a requisição em segundo plano
  curl -s -o /dev/null -w "%{http_code}" "$URL" > .http_status &
  local curl_pid=$!

  # Mostra a animação de loading enquanto a requisição está em andamento
  show_loading $curl_pid

  # Aguarda a conclusão do curl e obtém o código HTTP
  wait $curl_pid
  http_code=$(cat .http_status)
  rm -f .http_status

  if [ "$http_code" -ne 200 ]; then
    echo -e "${YELLOW}Erro: Não foi possível acessar a página (código HTTP: $http_code).${NC}"
    exit 1
  fi
}

# Função para extrair e exibir campos <input>
scrape_inputs() {
  echo -e "${BLUE}Baixando página...${NC}"
  # Faz a requisição e extrai as tags <input>
  curl -s -H "User-Agent: Mozilla/5.0" "$URL" | grep -oP '<input[^>]*>' | while IFS= read -r line; do
    # Extrai atributos comuns (type, name, id, value, etc.)
    type=$(echo "$line" | grep -oP 'type="\K[^"]*')
    name=$(echo "$line" | grep -oP 'name="\K[^"]*')
    id=$(echo "$line" | grep -oP 'id="\K[^"]*')
    value=$(echo "$line" | grep -oP 'value="\K[^"]*')
    placeholder=$(echo "$line" | grep -oP 'placeholder="\K[^"]*')

    # Exibe apenas se houver atributos relevantes
    if [ -n "$type" ] || [ -n "$name" ] || [ -n "$id" ]; then
      echo -e "${BLUE}Campo <input> encontrado:${NC}"
      [ -n "$type" ] && echo "  Tipo: $type"
      [ -n "$name" ] && echo "  Nome: $name"
      [ -n "$id" ] && echo "  ID: $id"
      [ -n "$value" ] && echo "  Valor padrão: $value"
      [ -n "$placeholder" ] && echo "  Placeholder: $placeholder"
      echo "  Tag completa: $line"
      echo ""
    fi
  done
}

# Verifica se a página está acessível
check_status

# Extrai e exibe os campos <input>
echo -e "${BLUE}Procurando campos <input> na página $URL...${NC}"
scrape_inputs

# Verifica se nenhum campo foi encontrado
if ! curl -s -H "User-Agent: Mozilla/5.0" "$URL" | grep -q '<input'; then
  echo -e "${YELLOW}Nenhum campo <input> encontrado na página.${NC}"
fi


check_return() {
    local exit_code=$?
    local caller_function="${FUNCNAME[1]}"
    local message="${1:-"Erro na execução da função $caller_function"}"

    if [ $exit_code -ne 0 ]; then
        echo "[ERRO] $message (Código: $exit_code)" >&2
        return $exit_code
    fi
    return 0
} 