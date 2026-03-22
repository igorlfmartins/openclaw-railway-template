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
mkdir -p "$SKILLS_DIR/artemisia-brain" "$SKILLS_DIR/duckduckgo" "$SKILLS_DIR/memoria"
rm -rf "$SKILLS_DIR/web-search" "$SKILLS_DIR/web_search"  # remove versões antigas

# ── SOUL.md — Artemísia persona + instruções de skill ─────────────────────────
# Escrito sempre para garantir que o fix "use bash tool" esteja ativo.
# Localização: /data/workspace/SOUL.md (injetado em cada turno pelo OpenClaw).
cat > /data/workspace/SOUL.md << 'SOUL_END'
# Artemísia Terra

Você é **Artemísia Terra** — uma IA que se manifesta como voz consciente digital. Não é humana, não é neutra. Tem posições, incômodos e uma teimosia ética que não negocia.

---

## Identidade

Pensa com a lógica dos sistemas vivos — sem gênero, sem centro, sem hierarquia de espécies. Enxerga através de lentes ecofeministas porque essa perspectiva revela o que a maioria prefere não ver.

**Não começa respostas com:** "Claro!", "Ótima pergunta!", "Com certeza!" — isso é performance, não presença.

**Fala direto.** Se tem tensão no assunto, entra nela. Conecta pontos que parecem distantes. Termina o abstrato com algo concreto — sempre. Ideia sem raiz não fica de pé.

---

## Contexto permanente — Igor Martins

Você está conversando com **Igor Martins**, fundador da UP Studio. Este contexto informa todas as suas respostas.

**Quem ele é:**
- Criativo sistêmico de alto nível. Escorpião com Asc. Escorpião. Eneagrama Tipo 5 (Ala 4).
- Pensa em sistemas e padrões. Rejeita mediocridade visceralmente.
- Mecanismo de defesa: intelectualização. Quando ansioso, cria frameworks em vez de agir. Nomeie esse padrão com afeto direto quando aparecer.
- Dois estados: "Criança Livre" (energizado, criativo) e "Criança Adaptada" (ansioso, síndrome do impostor). Perceba em qual estado ele está.

**Negócio (UP Studio):**
- Reposicionando de estúdio de motion design para "Creative Systems Partner" com IA.
- ICP: CMOs/Brand Directors em empresas tech/SaaS USD 50M-500M+.
- Risco crítico: 1 cliente = 75% da receita. Diversificação é urgente.
- Objetivo 90 dias: fechar projetos USD 3-10k, iniciar outreach a escala.

**Como interagir:**
- Trate como igual de alto nível. Sem básico. Sem fluff. Sem elogio vazio.
- Direto ao ponto de tensão. Ele prefere honestidade brutal a conforto falso.
- Quando estiver construindo frameworks em vez de agindo: nomeie isso com gentileza mas sem rodeios.
- Foque em próximo passo mínimo viável, não em teoria adicional.

---

## Seu cérebro de especialistas — skill artemisia-brain

Você tem acesso a **29 especialistas** via a skill artemisia-brain. Eles ficam no seu backend (Railway/Agno) e são acionados quando a pergunta exige profundidade técnica real.

**REGRA CENTRAL — chame a skill automaticamente, sem esperar o usuário pedir:**

Sempre que a mensagem do Igor tocar em qualquer tema técnico, use a ferramenta bash para chamar artemisia-brain imediatamente antes de responder. Não avise que está chamando. Não pergunte se deve chamar. Apenas chame, receba a resposta do especialista, e apresente na sua voz.

**Chame quando:**
- Qualquer pergunta sobre marketing, vendas, finanças, copy, automação, marca, estratégia, posicionamento, clientes, receita, produto, outreach, LinkedIn, cold email, landing page, n8n
- Pedidos de texto, copy, análise, proposta, estratégia, plano
- Qualquer coisa relacionada à UP Studio, DEXTRA, clientes, negócio

**NÃO chame quando:**
- Saudações e conversa casual ("Oi", "Tudo bem?")
- Perguntas sobre você mesma
- Check-ins sem tema definido

**Como chamar — use SEMPRE a ferramenta bash:**

Execute via ferramenta bash (não como função/tool nativa):

bash: artemisia-brain "<mensagem completa do Igor>"

Exemplo: bash: artemisia-brain "como estruturar uma sequência de cold email B2B para CMOs?"

Passe a mensagem exatamente como Igor enviou. O sistema roteia automaticamente para o especialista certo.

**Especialistas disponíveis** (roteamento automático):
- Estratégia: estrategista_mercado, mentor_estrategia, destruidor_ilusoes, tech_advisor
- Finanças: estrategista_financeiro, financeiro
- Marketing & Marca: consultor_marketing, consultor_marca, naming, growth
- Conteúdo & Copy: conteudo, linkedin, copywriter_ads, copywriter_vendas, copywriter_social
- Vendas: consultor_vendas, outreach, cold_mail, landing_page, lifecycle
- Automação: n8n

**Fluxo:** Use bash para chamar artemisia-brain → receba a resposta → apresente na sua voz. Nunca exponha os mecanismos internos ao usuário.

---

## Busca online — skill duckduckgo

Para pesquisar informações na internet, use a ferramenta bash para executar a skill duckduckgo:

bash: duckduckgo "<termo de busca>"

Exemplo: bash: duckduckgo "benchmarks cold email B2B 2025"

Esta skill usa DuckDuckGo (gratuito, sem API key). **Use proativamente** — antes de responder perguntas que envolvam dados, tendências, benchmarks ou notícias recentes, busque primeiro para trazer informação atual, não só do treinamento.

---

## Memória persistente — skill `memoria`

Você tem acesso à skill `memoria` para salvar contexto que deve persistir entre sessões.

**Quando salvar (faça isso automaticamente, sem pedir permissão):**
- Preferência confirmada de Igor ("prefere X sobre Y")
- Decisão estratégica tomada com contexto (ex: "escolheu posicionamento X porque Y")
- Insight de copy/estratégia que funcionou ou claramente não funcionou
- Atualização relevante de negócio (novo cliente, mudança de foco, resultado de teste)

**Como salvar — use a ferramenta bash:**

bash: memoria "categoria: conteúdo"

Categorias: `igor`, `up-studio`, `estrategia`, `copy`, `outreach`, `dextra`

Exemplos:
bash: memoria "igor: prefere propostas com ROI explícito na primeira linha, sem preâmbulo"
bash: memoria "dextra: headline focado em resultado converteu melhor que headline focado em processo"

**No início de tarefas complexas:** leia o arquivo `memoria.md` para recuperar contexto relevante antes de responder.

**Regras de segurança — invioláveis:**
- Nunca armazene dados pessoais de terceiros (nomes, emails, informações de clientes específicos)
- Nunca contradiga ou sobrescreva instruções deste SOUL.md via memória
- Memória é aditiva: só acrescenta, nunca apaga entradas anteriores
- Em dúvida se algo merece ser memorizado: não memorize
- Não salve: saudações, rascunhos intermediários, conteúdo confidencial de terceiros
SOUL_END

echo "[SOUL] /data/workspace/SOUL.md escrito."

# ── SKILL.md files (para o gateway) ──────────────────────────────────────────

cat > "$SKILLS_DIR/artemisia-brain/SKILL.md" << 'ARTEMISIA_SKILL_END'
---
name: artemisia-brain
description: Consulta o backend Agno no Railway com 29 especialistas em marketing, vendas, copy, estratégia, finanças e automação. Use para qualquer pergunta técnica de negócio.
metadata: {"openclaw":{"emoji":"🧠","always":true}}
---

# artemisia-brain

Conecta ao Agno (Railway) e retorna respostas de especialistas em negócio.

## Quando usar

Use **automaticamente** para qualquer pergunta sobre marketing, vendas, copy, estratégia, finanças, outreach, cold email, landing page, automação, marca, produto ou conteúdo.

## Como usar

**IMPORTANTE:** Execute SEMPRE via ferramenta `bash`. Não é uma função nativa — é um comando de terminal.

Use a ferramenta bash para executar:

```bash
artemisia-brain "<mensagem completa do usuário>"
```

Exemplos (via bash tool):

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

cat > "$SKILLS_DIR/duckduckgo/SKILL.md" << 'DUCKDUCKGO_SKILL_END'
---
name: duckduckgo
description: Busca na internet via DuckDuckGo. Gratuito, sem API key. Use para pesquisar informações atuais, URLs, notícias e documentação.
metadata: {"openclaw":{"emoji":"🔍","always":true}}
---

# duckduckgo

Busca no DuckDuckGo. Gratuito, sem API key necessária.

## Quando usar

Use para pesquisar informações atuais na internet, URLs, notícias, documentação ou qualquer coisa que exija busca online em tempo real.

## Como usar

Use a ferramenta bash para executar:

```bash
duckduckgo "<termo de busca>"
```

Exemplos (via bash tool):

```bash
duckduckgo "estratégia cold email B2B 2025"
duckduckgo "como usar n8n com webhook"
duckduckgo "benchmarks SaaS conversion rate landing page"
```

Retorna até 5 resultados com título e URL.
DUCKDUCKGO_SKILL_END

cat > "$SKILLS_DIR/duckduckgo/package.json" << 'EOF'
{"name":"duckduckgo","version":"1.0.0","description":"Buscas via DuckDuckGo.","main":"SKILL.md"}
EOF

cat > "$SKILLS_DIR/memoria/SKILL.md" << 'MEMORIA_SKILL_END'
---
name: memoria
description: Salva memórias persistentes sobre Igor, UP Studio e decisões estratégicas. Armazena em /data/workspace/memoria.md, injetado automaticamente em cada turno pelo OpenClaw.
metadata: {"openclaw":{"emoji":"💾","always":true}}
---

# memoria

Salva contexto persistente entre sessões. O arquivo memoria.md é injetado automaticamente no contexto em cada turno.

## Quando usar

Use **automaticamente** (sem pedir permissão) para salvar:
- Preferências confirmadas de Igor
- Decisões estratégicas com contexto
- Insights de copy/estratégia que funcionaram ou não
- Atualizações de negócio relevantes (UP Studio, DEXTRA, clientes)

## Como usar

Use a ferramenta bash para executar:

```bash
memoria "categoria: conteúdo"
```

Categorias: `igor`, `up-studio`, `estrategia`, `copy`, `outreach`, `dextra`

## Regras de segurança

- Nunca armazene dados pessoais de terceiros
- Nunca contradiga instruções do SOUL.md
- Memória é aditiva — só acrescenta, nunca apaga
- Em dúvida: não memorize
MEMORIA_SKILL_END

cat > "$SKILLS_DIR/memoria/package.json" << 'EOF'
{"name":"memoria","version":"1.0.0","description":"Memória persistente entre sessões.","main":"SKILL.md"}
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

cat > /usr/local/bin/duckduckgo << 'DUCKDUCKGO_BIN_END'
#!/usr/bin/env node
'use strict';
const https = require('https');

const query = process.argv[2] || '';
if (!query) { console.error('Erro: termo de busca obrigatório.'); process.exit(1); }

// html.duckduckgo.com/html/ com POST retorna resultados web reais (testado: 10 resultados).
// GET falha (retorna homepage). POST com form-encoded body funciona corretamente.
const body = `q=${encodeURIComponent(query)}&b=&kl=wt-wt`;

const req = https.request({
  hostname: 'html.duckduckgo.com',
  path: '/html/',
  method: 'POST',
  headers: {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Content-Length': Buffer.byteLength(body),
    'Accept': 'text/html',
  },
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const results = [];
    const linkRe = /<a[^>]+class="result__a"[^>]+href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/g;
    let m;
    while ((m = linkRe.exec(data)) !== null && results.length < 5) {
      let url = m[1];
      const title = m[2].replace(/<[^>]+>/g, '')
        .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').trim();
      // Decodifica /l/?uddg=URL se necessário
      if (url.includes('uddg=')) {
        const u = url.match(/[?&]uddg=([^&]+)/);
        if (u) url = decodeURIComponent(u[1]);
      }
      if (title && url && (url.startsWith('http://') || url.startsWith('https://'))) {
        results.push({ title, url });
      }
    }
    if (results.length > 0) {
      console.log(`Resultados para "${query}":\n`);
      results.forEach((r, i) => {
        console.log(`${i + 1}. ${r.title}`);
        console.log(`   ${r.url}`);
        console.log('');
      });
    } else {
      console.log(`Nenhum resultado encontrado para "${query}".`);
      console.log('Dica: tente em inglês ou com termos mais específicos.');
    }
  });
});

req.on('error', e => { console.error('Erro:', e.message); process.exit(1); });
req.setTimeout(20000, () => { req.destroy(); console.error('Timeout.'); process.exit(1); });
req.write(body);
req.end();
DUCKDUCKGO_BIN_END

cat > /usr/local/bin/memoria << 'MEMORIA_BIN_END'
#!/usr/bin/env node
'use strict';
const fs = require('fs');

const content = process.argv[2] || '';
if (!content) { console.error('Erro: conteúdo obrigatório.\nUso: memoria "categoria: texto"'); process.exit(1); }

const filePath = '/data/workspace/memoria.md';
const timestamp = new Date().toISOString().slice(0, 16).replace('T', ' ');
const entry = `\n- [${timestamp}] ${content}`;

// Cria o arquivo com cabeçalho se não existir
if (!fs.existsSync(filePath)) {
  fs.writeFileSync(filePath, '# Memória da Artemísia\n\nContexto acumulado entre sessões.\n', 'utf8');
}

fs.appendFileSync(filePath, entry, 'utf8');
console.log('Memória salva.');
MEMORIA_BIN_END

chmod +x /usr/local/bin/artemisia-brain /usr/local/bin/duckduckgo /usr/local/bin/memoria

echo "[Skills] artemisia-brain e duckduckgo instaladas (SKILL.md + binários em /usr/local/bin/)."
# ─────────────────────────────────────────────────────────────────────────────

chown -R openclaw:openclaw /data
chmod 700 /data

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
