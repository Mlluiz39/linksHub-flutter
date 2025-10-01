# Social Links CRUD

Um aplicativo Flutter para gerenciar links de redes sociais com operações CRUD (Create, Read, Update, Delete).

## Funcionalidades

- ✅ Adicionar links de redes sociais
- ✅ Visualizar lista de links cadastrados
- ✅ Editar links existentes
- ✅ Excluir links
- ✅ Pesquisar por plataforma ou usuário
- ✅ Abrir links diretamente no navegador
- ✅ Interface intuitiva com ícones das redes sociais
- ✅ Geração automática de URLs para plataformas populares

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── models/
│   └── social_link.dart      # Modelo de dados
├── services/
│   └── database_service.dart # Serviço de banco de dados SQLite
└── screens/
    ├── home_screen.dart      # Tela principal com lista
    └── add_edit_screen.dart  # Tela para adicionar/editar
```

## Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **SQLite**: Banco de dados local (sqflite)
- **URL Launcher**: Para abrir links externos
- **Font Awesome**: Ícones das redes sociais

## Plataformas Suportadas

O app suporta as seguintes redes sociais com geração automática de URLs:

- Instagram
- Facebook
- Twitter/X
- LinkedIn
- YouTube
- TikTok
- GitHub
- WhatsApp
- Telegram
- Snapchat
- Pinterest
- Discord

## Como Usar

1. **Adicionar Link**: Toque no botão "+" para adicionar um novo link
2. **Editar Link**: Toque nos três pontos e selecione "Editar"
3. **Abrir Link**: Toque diretamente no card ou use o menu "Abrir link"
4. **Excluir Link**: Use o menu de três pontos e selecione "Excluir"
5. **Pesquisar**: Use a barra de pesquisa para filtrar por plataforma ou usuário

## Instalação

### Pré-requisitos
- Flutter SDK instalado
- Android Studio ou VS Code com extensões Flutter
- Emulador Android ou dispositivo físico

### Passos

1. Clone ou copie o projeto
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o app:
   ```bash
   flutter run
   ```

## Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0         # Banco de dados SQLite
  path: ^1.8.3            # Manipulação de caminhos
  url_launcher: ^6.1.12   # Abrir URLs externas
  font_awesome_flutter: ^10.5.0  # Ícones
```

## Funcionalidades Técnicas

### Banco de Dados
- Utiliza SQLite para armazenamento local
- Estrutura da tabela inclui: id, platform, username, url, created_at, updated_at

### Interface
- Design Material 3
- Busca em tempo real
- Confirmação para exclusões
- Feedback visual para ações do usuário

### Validações
- Campos obrigatórios
- Validação de formato de URL
- Geração automática de URLs baseada na plataforma

## Possíveis Melhorias Futuras

- [ ] Backup e restauração de dados
- [ ] Categorização de links
- [ ] Estatísticas de uso
- [ ] Temas personalizáveis
- [ ] Compartilhamento de perfis
- [ ] Sincronização em nuvem
