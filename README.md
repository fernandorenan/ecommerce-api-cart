# Carrinho de compras de e-commerce

## Funcionalidades

### Gestão de Produtos
- CRUD completo de produtos (criar, listar, visualizar, atualizar, remover)
- Validação de dados (nome obrigatório, preço não negativo)

### Sistema de Carrinho
- Criação automática de carrinho baseada em sessão
- Adição e remoção de produtos do carrinho
- Cálculo automático de preços totais
- Atualização de quantidades
- Gestão de estado do carrinho (ativo, abandonado, concluído)

### Jobs em Background
- Limpeza automática de carrinhos abandonados (após 3 horas de inatividade)
- Remoção de carrinhos abandonados antigos (após 7 dias)
- Execução via Sidekiq com agendamento

### Internacionalização
- Suporte a múltiplos idiomas (Português BR e Inglês)
- Mensagens de erro e sucesso localizadas

## Informações técnicas

### Dependências
- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15

- Sidekiq: Processamento de jobs em background
- Rswag: Documentação automática da API
- RSpec: Testes automatizados
- RuboCop: Análise de código

### Como executar o projeto

## Executando a app sem o docker
Dado que todas as as ferramentas estão instaladas e configuradas:

Instalar as dependências do:
```bash
bundle install
```

Executar o sidekiq:
```bash
bundle exec sidekiq
```

Executar projeto:
```bash
bundle exec rails server
```

Executar os testes:
```bash
bundle exec rspec
```

## Executando a app com o docker

Para iniciar todos os serviços:
```bash
docker-compose up
```

Para iniciar em background:
```bash
docker-compose up -d
```

Para ver os logs:
```bash
docker-compose logs -f

Para executar os testes:
```bash
docker-compose run test
```

Para executar comandos do Rails:
```bash
docker-compose exec web bundle exec rails console
docker-compose exec web bundle exec rails db:migrate
```

## Acessando a Documentação

### Interface Web (Swagger UI)
Após iniciar o servidor Rails, você pode acessar a interface interativa do Swagger em:
```
http://localhost:3000/api-docs
```

## APIs Documentadas

### Produtos (`/products`)
- **GET** `/products` - Lista todos os produtos
- **POST** `/products` - Cria um novo produto  
- **GET** `/products/{id}` - Mostra um produto específico
- **PUT** `/products/{id}` - Atualiza um produto
- **DELETE** `/products/{id}` - Remove um produto

### Carrinho (`/cart`)
- **GET** `/cart` - Visualiza o carrinho atual
- **POST** `/cart` - Cria carrinho e adiciona produto
- **POST** `/cart/add_items` - Adiciona itens ao carrinho existente
- **DELETE** `/cart/{product_id}` - Remove produto do carrinho

## Monitoramento

### Interface do Sidekiq
Acesse o painel de monitoramento de jobs em:
```
http://localhost:3000/sidekiq
```
