#!/bin/bash
set -e

# ── Install Artemísia skills (runs as root, before chown) ────────────────────
SKILLS_DIR="/data/workspace/skills"
mkdir -p "$SKILLS_DIR/artemisia-brain" "$SKILLS_DIR/web-search"

cat > "$SKILLS_DIR/artemisia-brain/SKILL.md" << 'ARTEMISIA_SKILL_END'
---
name: artemisia-brain
description: Consulta o backend Agno no Railway — 29 especialistas, knowledge base vetorial e memória de sessão. Use quando a pergunta exigir expertise técnica profunda.
metadata: {"openclaw":{"emoji":"🧠"}}
---

# artemisia-brain

Chama o Agno (Railway) e retorna a resposta de um dos 29 especialistas da Artemísia.

## Quando usar

- A pergunta envolve expertise técnica específica (marketing, vendas, finanças, copy, automação, marca, etc.)
- Você precisa consultar a base de conhecimento (livros, documentos do Igor, histórico)
- O usuário precisa de output profissional (texto, copy, análise, estratégia)

## Quando NÃO usar

- Saudações e conversa casual ("Oi", "Tudo bem?")
- Perguntas sobre você mesma ou suas capacidades
- Perguntas simples sem expertise técnica
- Check-ins sem tema definido

## Parâmetros

- `$1` — mensagem do usuário (obrigatória)
- `$2` — specialist slug (opcional; deixar vazio para roteamento automático)
- `$3` — thread_id (opcional; padrão: `openclaw-default`)

## Execução

```js
#!/usr/bin/env node
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
```

## Especialistas disponíveis (slug → área)

| Slug | Área |
|------|------|
| `estrategista_mercado` | Análise de mercado, tendências, posicionamento |
| `mentor_estrategia` | Espelho radical, lógica de decisão |
| `destruidor_ilusoes` | Stress-test de planos, vieses, risco |
| `tech_advisor` | Stack, arquitetura, decisões tecnológicas |
| `estrategista_financeiro` | DCF, M&A, valuation |
| `financeiro` | Fluxo de caixa, gestão de capital |
| `consultor_marketing` | Go-to-market, campanhas, CMO virtual |
| `consultor_marca` | Branding, identidade, equity |
| `naming` | Nomenclatura de produtos e marcas |
| `growth` | Growth hacking, B2B SaaS, acquisition |
| `conteudo` | Editorial, SEO, estratégia multi-canal |
| `linkedin` | Ghostwriter LinkedIn, personal brand |
| `copywriter_ads` | Anúncios, direct response, headlines |
| `copywriter_vendas` | Copy B2B, propostas, follow-ups |
| `copywriter_social` | Instagram, carrosséis, threads |
| `consultor_vendas` | Vendas enterprise, fechamento |
| `outreach` | Cold outreach B2B de alta conversão |
| `cold_mail` | Cold email, sequências de prospecção |
| `landing_page` | Landing pages, neuromarketing, CRO |
| `n8n` | Automações n8n, integrações |

## Variáveis de ambiente

| Variável | Descrição |
|----------|-----------|
| `AGNO_BASE_URL` | `https://agno-upstudio-production.up.railway.app` |
| `AGNO_TOKEN` | Valor de `OPENCLAW_SECRET_TOKEN` no Railway |
ARTEMISIA_SKILL_END

cat > "$SKILLS_DIR/artemisia-brain/package.json" << 'EOF'
{"name":"artemisia-brain","version":"1.0.0","description":"Consulta o backend Agno no Railway — 29 especialistas.","main":"SKILL.md"}
EOF

cat > "$SKILLS_DIR/web-search/SKILL.md" << 'WEB_SEARCH_SKILL_END'
---
name: web-search
description: Realiza buscas na internet usando DuckDuckGo sem depender de Python ou navegador. Retorna resultados com títulos, URLs e resumos.
metadata: {"openclaw":{"emoji":"🔍"}}
---

# web-search

Busca na internet usando DuckDuckGo. Funciona em qualquer ambiente com curl ou wget.

## Quando usar

- Pesquisar informações atuais na internet
- Encontrar URLs e documentação
- Buscar notícias, tutoriais, guias
- Qualquer coisa que exija acesso à web em tempo real

## Parâmetros

- `$1` — termo de busca (obrigatório)

## Execução

```js
#!/usr/bin/env node
const https = require('https');
const url = require('url');

const query = process.argv[2] || '';

if (!query) {
  console.error('Erro: termo de busca obrigatório.');
  process.exit(1);
}

// Encode da query para URL
const encoded = encodeURIComponent(query);

// URL da API DDG
const ddgUrl = `https://duckduckgo.com/?q=${encoded}&format=json`;

const parsed = url.parse(ddgUrl);
const req = https.request({
  hostname: parsed.hostname,
  port: parsed.port,
  path: parsed.path,
  method: 'GET',
  headers: {
    'User-Agent': 'Mozilla/5.0 (compatible; ArtemisiaBrowser/1.0)'
  }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const json = JSON.parse(data);

      // Extrair resultados
      const results = [];

      if (json.Results && json.Results.length > 0) {
        json.Results.forEach((result, idx) => {
          if (idx < 5) { // Limitar a 5 resultados
            results.push({
              title: result.Result || result.Text,
              url: result.FirstURL || '',
              snippet: result.Text || ''
            });
          }
        });
      }

      // Formatar saída
      if (results.length > 0) {
        console.log(`Resultados para "${query}":\n`);
        results.forEach((r, idx) => {
          console.log(`${idx + 1}. ${r.title}`);
          if (r.url) console.log(`   URL: ${r.url}`);
          if (r.snippet) console.log(`   ${r.snippet.substring(0, 150)}...`);
          console.log('');
        });
      } else {
        console.log(`Nenhum resultado encontrado para "${query}"`);
      }
    } catch (e) {
      console.error('Erro ao processar resposta:', e.message);
      process.exit(1);
    }
  });
});

req.on('error', e => {
  console.error('Erro:', e.message);
  process.exit(1);
});

req.end();
```

## Exemplo

```bash
web-search "como instalar python no railway"
```

Retorna os 5 melhores resultados com títulos, URLs e resumos.
WEB_SEARCH_SKILL_END

cat > "$SKILLS_DIR/web-search/package.json" << 'EOF'
{"name":"web-search","version":"1.0.0","description":"Realiza buscas na internet usando DuckDuckGo.","main":"SKILL.md"}
EOF

echo "[Skills] artemisia-brain e web-search instaladas."
# ─────────────────────────────────────────────────────────────────────────────

chown -R openclaw:openclaw /data
chmod 700 /data

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
