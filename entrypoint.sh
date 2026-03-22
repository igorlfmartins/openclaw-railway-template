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
description: Consulta o backend Agno no Railway — 29 especialistas, knowledge base vetorial e memória de sessão. Use quando a pergunta exigir expertise técnica profunda.
metadata: {"openclaw":{"emoji":"🧠"}}
---

# artemisia-brain

Chama o Agno (Railway) e retorna a resposta de um dos 29 especialistas da Artemísia.

## Parâmetros

- `$1` — mensagem do usuário (obrigatória)
- `$2` — specialist slug (opcional)
- `$3` — thread_id (opcional; padrão: `openclaw-default`)

## Execução

```js
// executado via /usr/local/bin/artemisia-brain
```

## Especialistas disponíveis

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
description: Buscas na internet usando DuckDuckGo. Retorna títulos e URLs dos resultados.
metadata: {"openclaw":{"emoji":"🔍"}}
---

# web_search

Busca na internet usando DuckDuckGo via Node.js (sem dependências externas).

## Parâmetros

- `$1` — termo de busca (obrigatório)

## Execução

```js
// executado via /usr/local/bin/web_search
```
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
