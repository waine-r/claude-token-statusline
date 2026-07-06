# claude-token-statusline

[English](./README.md) · **Português**

Uma **statusline** nativa e simples para o [Claude Code](https://code.claude.com) no Windows (PowerShell) que mostra seu uso de tokens, a % do context window, o custo estimado e os **limites de uso do plano** (janela de sessão de 5h e janela semanal) logo abaixo da caixa de entrada — sem extensões de navegador, sem serviços externos, sem chaves de API, 100% local.

```
[Sonnet] ##-------- 25% | tokens in:15000 out:3000 | custo: $0.12
Plano | sessao 5h: 4% (reinicia 17:40) | semana: 20% (reinicia qui 13:00)
```

> A segunda linha espelha os "limites de uso do plano" mostrados no app do Claude para desktop. Ela só aparece para assinantes **Pro/Max** do Claude.ai e apenas depois da primeira resposta da API na sessão.

## Por quê

O Claude Code tem um recurso nativo de "statusline" — um script que recebe os dados da sessão (em JSON) via stdin e imprime de volta no terminal o que você quiser. A maioria dos exemplos online é escrita para bash/macOS/Linux. Este repositório é uma **versão pronta para uso em PowerShell** para usuários do Windows (incluindo o terminal integrado do VS Code), já que os exemplos em bash da documentação oficial falham com `ParserError` quando colados no PowerShell.

## O que ele mostra

- Modelo em uso no momento
- Uma barra de progresso de 10 caracteres do uso do context window
- Percentual de uso do context window
- Contagem de tokens de entrada / saída
- Custo estimado da sessão em USD
- Limites de uso do plano: janela de sessão de 5h e janela semanal, cada uma com % usado e horário de reset (somente Pro/Max)

## Requisitos

- Windows com PowerShell (já vem instalado, nada extra para instalar)
- [Claude Code](https://code.claude.com) já instalado e funcionando

## Instalação

1. Clone este repositório ou apenas baixe o `statusline.ps1`.

   ```powershell
   git clone https://github.com/waine-r/claude-token-statusline.git
   ```

2. Copie o `statusline.ps1` para a pasta de configuração do Claude Code:

   ```powershell
   copy statusline.ps1 $env:USERPROFILE\.claude\statusline.ps1
   ```

3. Abra (ou edite) o `$env:USERPROFILE\.claude\settings.json` e adicione o bloco `statusLine` do arquivo [`settings.example.json`](./settings.example.json), substituindo `YOUR_USERNAME` pelo seu nome de usuário do Windows. **Se você já tem um `settings.json` com outras chaves (plugins, tema, modelo, etc.), adicione apenas a chave `statusLine` — não sobrescreva o resto do arquivo.**

   Você pode fazer isso com segurança pelo PowerShell, sem editar o JSON na mão:

   ```powershell
   cd $env:USERPROFILE\.claude
   $settings = Get-Content settings.json -Raw | ConvertFrom-Json
   $statusLine = @{
       type = "command"
       command = "powershell -NoProfile -File `"$env:USERPROFILE\.claude\statusline.ps1`""
   }
   $settings | Add-Member -MemberType NoteProperty -Name "statusLine" -Value $statusLine -Force
   $settings | ConvertTo-Json -Depth 10 | Out-File -FilePath settings.json -Encoding utf8
   ```

4. Teste o script diretamente (opcional, mas recomendado):

   ```powershell
   '{"model":{"display_name":"Sonnet"},"context_window":{"used_percentage":25,"total_input_tokens":15000,"total_output_tokens":3000},"cost":{"total_cost_usd":0.12},"rate_limits":{"five_hour":{"used_percentage":4,"resets_at":1783370400},"seven_day":{"used_percentage":20,"resets_at":1783612800}}}' | .\statusline.ps1
   ```

   Saída esperada (a segunda linha é omitida automaticamente se `rate_limits` não estiver presente):

   ```
   [Sonnet] ##-------- 25% | tokens in:15000 out:3000 | custo: $0.12
   Plano | sessao 5h: 4% (reinicia 17:40) | semana: 20% (reinicia qui 13:00)
   ```

5. Reinicie o Claude Code (`claude`). A statusline deve aparecer abaixo da caixa de entrada, atualizando conforme você conversa.

## Personalizando

O script é um único arquivo PowerShell curto — sinta-se à vontade para editar o `statusline.ps1` e:
- Mudar cores (adicionar códigos ANSI)
- Mostrar/esconder campos
- Mudar a largura ou os caracteres da barra
- Adicionar branch do git, data/hora, etc.

O Claude Code envia o JSON completo da sessão a cada renderização — consulte a [documentação oficial da statusline](https://code.claude.com/docs/statusline) para todos os campos disponíveis (modelo, context window, custo, workspace, output style e mais).

## Observações

- Roda 100% localmente — nenhum dado sai da sua máquina, sem chamadas de API, sem custo extra.
- Afeta apenas a exibição no terminal; não altera o comportamento nem os limites reais do Claude Code.
- Testado no Windows 10/11, PowerShell 5.1+, usando o terminal integrado do VS Code.

## Licença

MIT — faça o que quiser com ele.
