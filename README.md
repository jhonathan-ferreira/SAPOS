# 🐸 SAPOS - Scripts Auxiliares de POS 🐸

**SAPOS** é uma ferramenta em script que centraliza utilitários para auxiliar na manutenção do POS e seus componentes no Windows.  
Através de um menu interativo, permite executar correções comuns de forma prática, rápida e segura.

## 🚀 Funcionalidades

Atualmente, o SAPOS oferece as seguintes opções:

### 1. BASE ZERO
Baixa um arquivo de base de dados do POS zerado, realiza o backup da base atual e substitui por uma base zerada.

### 2. TESTES DE REDE
Realiza testes de comunicação com os endpoints do POS, portas locais e outras URLs essenciais a fim de verificar possíveis bloqueios de rede. Caso algum teste falhe, apresenta a opção de alterar o DNS e desativar o Firewall.

### 3. REPARAR WMI
Verifica se o WMI (Windows Management Instrumentation) está corrompido e, caso esteja, tenta realizar reparos.

### 4. ATUALIZAR DLL SAT
Copia o arquivo .dll (e outros arquivos se necessário) da pasta do software do fabricante para as pastas necessárias para o funcionamento com o POS, substituindo os arquivos antigos. Atualmente suporta 3 modelos: Bematech SAT GO, Elgin Smart e Elgin Linker II.

### 5. HABILITAR WEBVIEW2
Muda o valor do registro do WebView2 para considerar como um programa e constar na listagem de Programas e Recursos do painel de controle, sendo possível realizar o reparo quando necessário.
