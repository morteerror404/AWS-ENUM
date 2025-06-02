# EC2 Instance Metadata Service (IMDS) Explorer  

Este repositório contém informações estruturadas sobre os metadados disponíveis no **AWS EC2 Instance Metadata Service (IMDS)**.  

## 🌐 URL Base  
Todos os metadados podem ser acessados via:  
```
http://169.254.169.254/latest/meta-data/
```

## 📂 Estrutura dos Metadados  

```
metadata/
├── ami-id                             # ID da AMI da instância
├── ami-launch-index                   # Índice no grupo de lançamento
├── ami-manifest-path                  # Caminho do manifesto da AMI
├── ancestor-ami-ids                   # AMIs ancestrais (se derivada)
├── hostname                           # Hostname privado (DNS)
├── instance-action                    # Ação agendada (stop/terminate)
├── instance-id                        # ID da instância
├── instance-life-cycle                # "on-demand" ou "spot"
├── instance-type                      # Tipo (ex: t2.micro)
├── local-hostname                     # Hostname local
├── local-ipv4                         # IPv4 privado
├── mac                                # MAC da interface primária
├── profile                            # Perfil (ex: default-hvm)
├── public-hostname                    # Hostname público (se houver)
├── public-ipv4                        # IPv4 público (se houver)
├── reservation-id                     # ID da reserva
│
├── network/                           # Dados de rede
│   └── interfaces/
│       └── macs/
│           └── [MAC_ADDRESS]/         # MAC da interface
│               ├── device-number       # Número do dispositivo
│               ├── interface-id        # ID da interface
│               ├── ipv4-associations/  # IPs públicos associados
│               │   └── [PUBLIC_IPV4]   # IPv4 específico
│               ├── local-hostname      # Hostname local
│               ├── local-ipv4s         # IPv4s privados
│               ├── mac                 # Endereço MAC
│               ├── owner-id            # ID do proprietário
│               ├── public-hostname     # Hostname público
│               ├── public-ipv4s        # IPv4s públicos
│               ├── security-group-ids  # IDs dos Security Groups
│               ├── security-groups     # Nomes dos Security Groups
│               ├── subnet-id           # ID da subnet
│               ├── subnet-ipv4-cidr-block  # Bloco CIDR da subnet
│               ├── vpc-id              # ID da VPC
│               └── vpc-ipv4-cidr-block # Bloco CIDR da VPC
│
├── iam/                               # Dados do IAM
│   ├── info                           # Informações da IAM Role
│   └── security-credentials/          # Credenciais temporárias
│       └── [ROLE_NAME]                # Nome da IAM Role
│
├── user-data                          # User Data (base64)
│
├── hibernation/                       # Config de hibernação
│   └── configured                     # "true" ou "false"
│
├── spot/                              # Spot Instance
│   ├── instance-action                # Ação (terminate, stop)
│   └── termination-time               # Horário de término
│
├── dynamic/                           # Metadados dinâmicos (IMDSv2)
│   └── instance-identity/
│       ├── document                   # JSON com metadados
│       ├── pkcs7                      # Assinatura PKCS7
│       └── signature                  # Assinatura
│
├── elastic-gpus/                      # Elastic GPUs
│   └── associations/
│       └── elastic-gpu-id             # ID do Elastic GPU
│
├── elastic-inference/                 # Elastic Inference
│   └── associations/
│       └── eia-id                     # ID do acelerador
│
├── placement/                         # Placement Group e AZ
│   ├── group-name                     # Nome do placement group
│   ├── availability-zone              # Zona de disponibilidade
│   └── region                         # Região AWS
│
└── tags/                              # Tags (IMDSv2 apenas)
    ├── instance                       # Todas as tags
    └── instance/
        └── [TAG_KEY]                  # Valor de uma tag específica
```

## 🔍 Como Usar  
### Exemplos de Consulta:  
1. **Metadados básicos**:  
   ```sh
   curl http://169.254.169.254/latest/meta-data/instance-id
   ```

2. **Credenciais IAM**:  
   ```sh
   curl http://169.254.169.254/latest/meta-data/iam/security-credentials/[ROLE_NAME]
   ```

3. **User Data**:  
   ```sh
   curl http://169.254.169.254/latest/user-data | base64 --decode
   ```

4. **Documento de identidade (JSON)**:  
   ```sh
   curl http://169.254.169.254/latest/dynamic/instance-identity/document
   ```

## ⚠️ Segurança  
- **IMDSv1 vs. IMDSv2**:  
  - IMDSv2 (mais seguro) exige tokens de sessão.  
  - Tags só estão disponíveis no IMDSv2.  
- **Acesso restrito**:  
  - Metadados só são acessíveis **de dentro da instância**.  
  - Nunca exponha credenciais ou User Data sensíveis.  

## 📚 Referência Oficial  
[AWS Documentation - EC2 Instance Metadata](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)  

---

Feito com ❤️ para exploradores de metadados AWS! 🚀