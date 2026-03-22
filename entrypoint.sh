#!/bin/bash
set -e

# ── Install Artemísia skills ──────────────────────────────────────────────────
# 1. SKILL.md files → gateway recognizes the skills (shows to AI)
# 2. Executables in /usr/local/bin/ → sh can find them when OpenClaw calls them
#
# OpenClaw executes skills as shell commands: sh -c "<skill-name> <args>"
# Without a real executable in PATH, it fails with "not found".
# ─────────────────────────────────────────────────────────────────────────────

SKILLS_DIR="/data/workspace/skills"
mkdir -p "$SKILLS_DIR/artemisia-brain" "$SKILLS_DIR/web_search"
rm -rf "$SKILLS_DIR/web-search"  # remove versão antiga com hífen

# ── SKILL.md files (para o gateway) ──────────────────────────────────────────

cat > "$SKILLS_DIR/artemisia-brain/SKILL.md" << 'ARTEMISIA_SKILL_END'
---
name: artemisia-brain
description: Consulta o backend Agno no Railway com 29 especialistas em marketing, vendas, copy, estratégia, finanças e automação. Use para qualquer pergunta técnica de negócio.
metadata: {"openclaw":{"emoji":"🧠","requires":{"bins":["artemisia-brain"]}}}
---

# artemisia-brain

Conecta ao Agno (Railway) e retorna respostas de especialistas em negócio.

## Quando usar

Use **automaticamente** para qualquer pergunta sobre marketing, vendas, copy, estratégia, finanças, outreach, cold email, landing page, automação, marca, produto ou conteúdo.

## Como usar

```bash
artemisia-brain "<mensagem completa do usuário>"
```

Exemplos:

```bash
artemisia-brain "como estruturar uma sequência de cold email B2B para CMOs?"
artemisia-brain "crie um headline para landing page de SaaS"
artemisia-brain "estratégia de go-to-market para produto de R$497"
```

## Especialistas disponíveis (roteamento automático)

estrategista_mercado, mentor_estrategia, destruidor_ilusoes, tech_advisor,
estrategista_financeiro, financeiro, consultor_marketing, consultor_marca,
naming, growth, conteudo, linkedin, copywriter_ads, copywriter_vendas,
copywriter_social, consultor_vendas, outreach, cold_mail, landing_page, n8n
ARTEMISIA_SKILL_END

cat > "$SKILLS_DIR/artemisia-brain/package.json" << 'EOF'
{"name":"artemisia-brain","version":"1.0.0","description":"Consulta o backend Agno — 29 especialistas.","main":"SKILL.md"}
EOF

cat > "$SKILLS_DIR/web_search/SKILL.md" << 'WEB_SEARCH_SKILL_END'
---
name: web_search
description: Busca na internet via DuckDuckGo. Sem dependências externas, sem API key. Use para pesquisar informações atuais, URLs, notícias e documentação.
metadata: {"openclaw":{"emoji":"🔍","requires":{"bins":["web_search"]}}}
---

# web_search

Busca no DuckDuckGo. Gratuito, sem API key necessária.

## Quando usar

Use para pesquisar informações atuais na internet, URLs, notícias, documentação ou qualquer coisa que exija busca online em tempo real.

## Como usar

```bash
web_search "<termo de busca>"
```

Exemplos:

```bash
web_search "estratégia cold email B2B 2025"
web_search "como usar n8n com webhook"
web_search "benchmarks SaaS conversion rate landing page"
```

Retorna até 5 resultados com título e URL.
WEB_SEARCH_SKILL_END

cat > "$SKILLS_DIR/web_search/package.json" << 'EOF'
{"name":"web_search","version":"1.0.0","description":"Buscas via DuckDuckGo.","main":"SKILL.md"}
EOF

# ── Executáveis reais em /usr/local/bin/ ──────────────────────────────────────
# OpenClaw chama skills via: sh -c "<skill-name> <args>"
# Precisa de um binário real no PATH.

cat > /usr/local/bin/artemisia-brain << 'ARTEMISIA_BIN_END'
#!/usr/bin/env node
'use strict';
const https = require('https');
const http = require('http');
const url = require('url');

const message = process.argv[2] || '';
const specialist = process.argv[3] || '';
const threadId = process.argv[4] || 'openclaw-default';

const baseUrl = process.env.AGNO_BASE_URL || '';
const token = process.env.AGNO_TOKEN || '';

if (!message) { console.error('Erro: mensagem obrigatória.'); process.exit(1); }
if (!baseUrl) { console.error('Erro: AGNO_BASE_URL não configurado.'); process.exit(1); }
if (!token) { console.error('Erro: AGNO_TOKEN não configurado.'); process.exit(1); }

const fullMessage = specialist ? `${message}\n[ESPECIALISTA SOLICITADO: ${specialist}]` : message;
const body = JSON.stringify({ message: fullMessage, thread_id: threadId });

const parsed = url.parse(baseUrl + '/chat');
const lib = parsed.protocol === 'https:' ? https : http;

const req = lib.request({
  hostname: parsed.hostname,
  port: parsed.port,
  path: parsed.path,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-OpenClaw-Token': token,
    'Content-Length': Buffer.byteLength(body),
  },
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      console.log(json.response || data);
    } catch { console.log(data); }
  });
});

req.on('error', e => { console.error('Erro:', e.message); process.exit(1); });
req.setTimeout(90000, () => { req.destroy(); console.error('Timeout.'); process.exit(1); });
req.write(body);
req.end();
ARTEMISIA_BIN_END

cat > /usr/local/bin/web_search << 'WEB_SEARCH_BIN_END'
#!/usr/bin/env node
'use strict';
const https = require('https');

const query = process.argv[2] || '';
if (!query) { console.error('Erro: termo de busca obrigatório.'); process.exit(1); }

const encoded = encodeURIComponent(query);
const path = `/?q=${encoded}&format=json`;

const req = https.request({
  hostname: 'duckduckgo.com',
  path,
  method: 'GET',
  headers: { 'User-Agent': 'Mozilla/5.0 (compatible; ArtemisiaBrowser/1.0)' },
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      const results = (json.Results || []).slice(0, 5);
      if (results.length > 0) {
        console.log(`Resultados para "${query}":\n`);
        results.forEach((r, i) => {
          console.log(`${i + 1}. ${r.Text || r.Result || ''}`);
          if (r.FirstURL) console.log(`   ${r.FirstURL}`);
          console.log('');
        });
      } else if (json.AbstractText) {
        console.log(json.AbstractText);
        if (json.AbstractURL) console.log(`Fonte: ${json.AbstractURL}`);
      } else {
        console.log(`Nenhum resultado encontrado para "${query}"`);
      }
    } catch (e) { console.error('Erro ao processar resposta:', e.message); process.exit(1); }
  });
});

req.on('error', e => { console.error('Erro:', e.message); process.exit(1); });
req.setTimeout(15000, () => { req.destroy(); console.error('Timeout.'); process.exit(1); });
req.end();
WEB_SEARCH_BIN_END

chmod +x /usr/local/bin/artemisia-brain /usr/local/bin/web_search

echo "[Skills] artemisia-brain e web_search instaladas (SKILL.md + binários em /usr/local/bin/)."
# ─────────────────────────────────────────────────────────────────────────────

chown -R openclaw:openclaw /data
chmod 700 /data

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
