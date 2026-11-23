# SpacingTRepetition

Aplicativo de estudos desenvolvido em **Flutter e Dart**, com quizzes personalizados, materiais de estudo e revisão espaçada de conteúdos.

O foco do projeto é o **aplicativo Android com armazenamento local**. A versão **Flutter Web** é utilizada apenas para apresentar o sistema em um computador, sem depender de uma API ou de um banco de dados remoto.

## Funcionalidades

- Criar, listar, editar e excluir categorias.
- Criar, editar e excluir quizzes com perguntas e quatro alternativas.
- Responder quizzes e consultar os resultados.
- Criar, editar, excluir e consultar materiais de estudo.
- Utilizar o modo **Class** para ler materiais antes de responder ao quiz.
- Registrar tentativas e calcular a próxima revisão com base na porcentagem de acertos.
- Visualizar revisões pendentes por meio de **avisos dentro do aplicativo**.
- Consultar estatísticas de estudo e calendário no perfil local.
- Exportar questões e materiais em formato CSV.
- Criar uma categoria e um quiz de exemplo na inicialização de um banco novo.

> Os avisos de revisão são internos ao aplicativo; não são notificações push nem notificações do sistema operacional.

## Tecnologias utilizadas

| Tecnologia / ferramenta | Utilização no projeto |
| --- | --- |
| **Flutter** e **Dart** | Interface, navegação e lógica do aplicativo. |
| **SQLite** | Armazenamento local de categorias, quizzes, questões, respostas e revisões. |
| **Drift** e **drift_flutter** | Mapeamento das tabelas, acesso ao banco, transações e consultas reativas. |
| **drift_dev** e **build_runner** | Geração das classes de acesso ao banco. |
| **SQLite WebAssembly (WASM)** | Execução do banco local no navegador durante a apresentação. |
| **share_plus** e **cross_file** | Exportação e compartilhamento de arquivos CSV. |
| **Material Design** | Componentes da interface Flutter. |
| **flutter_lints** e **flutter analyze** | Regras e análise estática do código. |
| **Android Studio**, **Git** e **GitHub** | Desenvolvimento e versionamento do projeto. |

## Organização do código

```text
lib/
├── app/                         # Inicialização do aplicativo
├── core/
│   ├── database/                # AppDatabase e StartDataSeeder
│   └── theme/                   # Tema e cores
├── feature/
│   ├── category/                # Categorias
│   ├── home/                    # Tela inicial
│   ├── notification/            # Avisos internos de revisão
│   ├── profile/                 # Histórico e indicadores
│   ├── quiz/                    # Quizzes, perguntas e respostas
│   ├── review/                  # Tentativas e agendamentos
│   └── studymaterial/           # Materiais de estudo
├── util/                        # Repetição espaçada e exportação CSV
└── main.dart
```

## Como executar

**Pré-requisitos:** Flutter SDK configurado, Dart SDK incluído no Flutter e Android Studio ou outro editor compatível.

### 1. Clonar o repositório

```bash
git clone https://github.com/lelegSpears/spacing-t-repetition-flutter.git
cd spacing-t-repetition-flutter
```

### 2. Instalar as dependências

```bash
flutter pub get
```

### 3. Gerar o código do Drift

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Executar no Android

Conecte um dispositivo ou inicie um emulador e consulte os dispositivos disponíveis:

```bash
flutter devices
flutter run
```

Caso apareçam vários dispositivos, selecione o Android com `flutter run -d ID_DO_DISPOSITIVO`.

### 5. Executar no navegador (apresentação)

A pasta `web/` deve conter os arquivos **`sqlite3.wasm`** e **`drift_worker.dart.js`** compatíveis com a versão do Drift instalada.

```bash
flutter run -d chrome
```

Se for necessário **regerar apenas o worker** a partir do arquivo `web/drift_worker.dart`:

```bash
dart compile js -O4 web/drift_worker.dart -o web/drift_worker.dart.js
```

Esse comando não substitui o arquivo `sqlite3.wasm`, que deve existir separadamente.

## Comandos úteis

| Comando | Finalidade |
| --- | --- |
| `flutter doctor` | Verificar a configuração do ambiente. |
| `flutter devices` | Listar dispositivos disponíveis. |
| `flutter pub get` | Instalar dependências do `pubspec.yaml`. |
| `dart run build_runner build --delete-conflicting-outputs` | Gerar/atualizar os arquivos do Drift. |
| `dart run build_runner watch --delete-conflicting-outputs` | Atualizar o código gerado ao modificar as tabelas. |
| `flutter analyze` | Verificar problemas de análise estática. |
| `flutter run` | Executar em um dispositivo selecionado. |
| `flutter run -d chrome` | Executar a versão Web. |
| `flutter build apk --release` | Gerar o APK em `build/app/outputs/flutter-apk/`. |
| `flutter build web --release` | Gerar os arquivos Web em `build/web/`. |

## Armazenamento dos dados

O banco é **local**. No Android, os dados ficam armazenados no próprio dispositivo. Na versão Web, ficam no armazenamento do navegador por meio do SQLite/WebAssembly. **Não existe sincronização entre dispositivos ou contas de usuário.** Limpar os dados do site pode apagar as informações locais.

## Testes e limitações

O projeto **não possui testes automatizados implementados**. O comando `flutter analyze` pode verificar problemas de análise estática, mas **não equivale a executar testes**.

A versão Web é destinada **somente à demonstração em computador durante a apresentação acadêmica**; o objetivo principal do projeto é o uso local no Android.

## Documentação e diagramas estão na pasta doc 

## Contexto acadêmico

Projeto desenvolvido para a disciplina de Engenharia de Software da **Universidade de Mogi das Cruzes (UMC)**, no 4º semestre.
