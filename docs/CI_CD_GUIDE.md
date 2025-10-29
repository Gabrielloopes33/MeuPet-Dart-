# MeuPet CI/CD Configuration Guide

Este guia explica como configurar e usar a esteira de CI/CD do MeuPet.

## 📋 Visão Geral

A esteira de CI/CD do MeuPet é composta por 6 workflows principais:

1. **🔍 Code Quality** - Análise estática e segurança
2. **🧪 Tests** - Testes unitários e cobertura
3. **🤖 Android Build** - Build e deploy Android
4. **🍎 iOS Build** - Build e deploy iOS
5. **🌐 Web Build** - Build e deploy Web
6. **🚀 CI/CD Pipeline** - Orquestrador principal

## 🔧 Configuração Inicial

### 1. Configurar Secrets do GitHub

Vá para **Settings > Secrets and variables > Actions** no seu repositório e adicione:

#### Android Deployment
```
KEYSTORE_FILE - Keystore em base64 (keytool -genkey -v -keystore android/app/keystore.jks)
KEYSTORE_PASSWORD - Senha do keystore
KEY_ALIAS - Alias da chave
KEY_PASSWORD - Senha da chave
GOOGLE_PLAY_SERVICE_ACCOUNT - JSON do Service Account do Google Play
```

#### iOS Deployment (opcional)
```
IOS_CERTIFICATE - Certificado .p12 em base64
IOS_CERTIFICATE_PASSWORD - Senha do certificado
IOS_PROVISIONING_PROFILE - Provisioning profile em base64
IOS_TEAM_ID - Team ID da Apple
IOS_APP_ID - App ID do App Store Connect
IOS_API_KEY - API Key do App Store Connect
IOS_API_ISSUER - API Issuer ID
```

#### Web Deployment
```
FIREBASE_SERVICE_ACCOUNT - Service Account do Firebase (opcional)
FIREBASE_PROJECT_ID - ID do projeto Firebase (opcional)
```

#### Notifications
```
SLACK_WEBHOOK - Webhook do Slack para notificações (opcional)
EMAIL_USERNAME - Usuário SMTP para emails (opcional)  
EMAIL_PASSWORD - Senha SMTP (opcional)
NOTIFICATION_EMAIL - Email para receber notificações (opcional)
```

### 2. Configurar Android Keystore

```bash
# Gerar keystore
keytool -genkey -v -keystore android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias meupet

# Converter para base64
base64 android/app/keystore.jks | tr -d '\n'
```

Adicione no `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Configurar Permissions

Adicione as seguintes permissões ao repositório:

**Settings > Actions > General:**
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

**Settings > Pages:**
- Source: GitHub Actions (para deploy web)

## 🚀 Como Usar

### Triggers Automáticos

| Evento | Workflows Executados | Plataformas | Deploy |
|--------|---------------------|-------------|---------|
| Push para `main` | Todos | Android, Web | Staging |
| Push para `develop` | Quality, Tests | - | - |
| Pull Request | Quality, Tests, Android (debug) | Android (debug) | - |
| Tag `v*` | Todos | Todas | Production |
| Manual (workflow_dispatch) | Escolhido | Configurável | Configurável |

### Deploy Manual

Para fazer deploy manual:

1. Vá para **Actions > CI/CD Pipeline**
2. Clique em **Run workflow**
3. Escolha a branch e ambiente
4. Clique em **Run workflow**

### Versionamento

Para release de produção:

```bash
# Criar tag de versão
git tag v1.0.0
git push origin v1.0.0
```

Isso irá:
- ✅ Executar todos os testes
- ✅ Buildar para todas as plataformas  
- 🚀 Deploy para produção (Play Store, App Store, Firebase)

## 📊 Monitoramento

### Build Status

Monitore o status dos builds através dos badges no README:
- [![CI/CD Pipeline](https://github.com/Gabrielloopes33/MeuPet-Dart-/actions/workflows/ci_cd.yml/badge.svg)](https://github.com/Gabrielloopes33/MeuPet-Dart-/actions/workflows/ci_cd.yml)

### Artifacts

Os workflows geram artifacts que podem ser baixados:
- **Android**: APK/AAB files
- **iOS**: IPA/Archive files  
- **Web**: Build completo
- **Coverage**: Relatórios HTML

### Logs e Debugging

Para debuggar falhas:

1. Vá para **Actions** > Selecione o workflow falhado
2. Clique no job com erro
3. Expanda as etapas para ver logs detalhados
4. Use `Re-run jobs` se for um erro temporário

## 🔧 Customização

### Modificar Workflows

Os workflows estão em `.github/workflows/`:
- `code_quality.yml` - Análise de código
- `tests.yml` - Testes e cobertura
- `android.yml` - Build Android
- `ios.yml` - Build iOS
- `web.yml` - Build Web
- `ci_cd.yml` - Pipeline principal

### Adicionar Novos Checks

Para adicionar novos checks de qualidade, edite `.github/workflows/code_quality.yml`:

```yaml
- name: 🔒 Meu Check Customizado
  run: |
    echo "Executando meu check..."
    # Seu comando aqui
```

### Configurar Ambientes

Para usar environments do GitHub:

1. Vá para **Settings > Environments**
2. Crie environments: `staging`, `production`
3. Configure protection rules e secrets por ambiente

## 🚨 Troubleshooting

### Problemas Comuns

**Build Android falha:**
- ✅ Verifique se KEYSTORE_* secrets estão configurados
- ✅ Confirme que `android/key.properties` é criado corretamente
- ✅ Verifique versões do Java/Flutter

**Testes falham:**
- ✅ Execute `flutter test` localmente primeiro
- ✅ Verifique dependências em `pubspec.yaml`
- ✅ Confirme que não há hardcoded paths

**Deploy falha:**
- ✅ Verifique permissões do GitHub Actions
- ✅ Confirme que secrets estão configurados
- ✅ Verifique logs detalhados do workflow

### Debug Local

Simule a CI localmente:

```bash
# Executar checks de qualidade
flutter analyze
dart format --output=none --set-exit-if-changed .

# Executar testes
flutter test --coverage

# Builds
flutter build apk --debug
flutter build web --release
```

### Suporte

Para dúvidas sobre CI/CD:
- 📄 Abra uma [Issue de Documentation](/.github/ISSUE_TEMPLATE/documentation.yml)
- 💬 Use [GitHub Discussions](../../discussions)
- 📧 Entre em contato com mantenedores

---

**Happy Building!** 🚀