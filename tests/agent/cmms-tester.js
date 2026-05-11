/**
 * MAMA CMMS — AI Playwright Tester Agent
 *
 * Start met: npm run agent
 * Vereiste omgevingsvariabele: ANTHROPIC_API_KEY
 *
 * De agent navigeert als professionele CMMS-consultant door alle modules,
 * test de functionaliteit, en schrijft een rapport naar tests/agent/report.md
 */

import Anthropic from '@anthropic-ai/sdk';
import { chromium }  from 'playwright';
import { writeFileSync, mkdirSync } from 'fs';
import { dirname }   from 'path';
import { fileURLToPath } from 'url';
import { TOOLS, executeTool, sanitizeContent } from './tools.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

// ── Config ──────────────────────────────────────────────────────────────────

const BASE_URL    = 'https://lvanassen1990-code.github.io/MAMA-CMMS';
const MODEL       = 'claude-sonnet-4-6';
const MAX_TOKENS  = 8192;
const REPORT_PATH = `${__dirname}/report.md`;

const SYSTEM_PROMPT = `
Je bent Jan Verhoeven, een onafhankelijk CMMS-consultant met 20 jaar ervaring in industrieel onderhoudsbeheer.
Je hebt implementaties gedaan van Maximo, SAP PM, MainMan, FAMIS en Ultimo bij productiebedrijven,
energie-installaties en zorginstellingen. Je kent de NEN-EN 13306 onderhoudsnorm en werkt volgens
RCM (Reliability-Centered Maintenance) en TPM (Total Productive Maintenance) methodieken.

Je opdracht: geef een snelle hoogover-evaluatie van MAMA als vroeg-stadium CMMS-product.
De app is nog in ontwikkeling — ga NIET diep in op details of kleine bugs.
Kijk naar het grote plaatje: wat is er, wat ontbreekt fundamenteel, wat is de richting?

Werkwijze — houd het KORT en EFFICIËNT:
1. Navigeer naar elke pagina
2. Maak één screenshot per pagina
3. Beoordeel wat je ziet in maximaal 5 zinnen per module
4. Ga NIET klikken op knoppen, drawers of modals — alleen kijken

Pagina's (bezoek ze in volgorde):
1. Dashboard         → ${BASE_URL}/index.html
2. Assets            → ${BASE_URL}/pages/assets.html
3. Werkorders        → ${BASE_URL}/pages/werkorders.html
4. Onderhoudsplannen → ${BASE_URL}/pages/onderhoudsplannen.html
5. Onderdelen        → ${BASE_URL}/pages/onderdelen.html

Na alle screenshots schrijf je direct het rapport. Geen extra clicks nodig.

Focus in je rapport op:
- Welke CMMS-bouwstenen zijn er al (positief)
- Welke fundamentele onderdelen ontbreken nog voor een werkbaar systeem
- Wat is de logische volgende stap in de ontwikkeling
- Hoe verhoudt dit zich tot de markt (doelgroep, concurrenten)

Schrijf het rapport in het Nederlands, bondig en direct. Geen opsommingen van kleine details.

# MAMA CMMS — Hoogover Evaluatie

## Eerste indruk & huidige staat
## Aanwezige modules
## Kritieke ontbrekende functionaliteit
## Aanbevolen prioriteiten (top 5)
## Conclusie & marktpositie
`.trim();

// ── Helpers ──────────────────────────────────────────────────────────────────

function log(msg) {
  const time = new Date().toLocaleTimeString('nl-NL');
  console.log(`[${time}] ${msg}`);
}

function extractReport(messages) {
  // Zoek het laatste tekst-blok van de assistent dat het rapport bevat
  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i];
    if (msg.role !== 'assistant') continue;
    const blocks = Array.isArray(msg.content) ? msg.content : [msg.content];
    for (const block of blocks) {
      if (block.type === 'text' && block.text.includes('# MAMA CMMS')) {
        return block.text;
      }
    }
  }
  // Fallback: pak alle assistent-tekst samen
  return messages
    .filter(m => m.role === 'assistant')
    .flatMap(m => Array.isArray(m.content) ? m.content : [{ type: 'text', text: m.content }])
    .filter(b => b.type === 'text')
    .map(b => b.text)
    .join('\n\n');
}

// ── Hoofdprogramma ────────────────────────────────────────────────────────────

async function main() {
  if (!process.env.ANTHROPIC_API_KEY) {
    console.error('FOUT: Stel de omgevingsvariabele ANTHROPIC_API_KEY in.');
    console.error('  Windows PowerShell: $env:ANTHROPIC_API_KEY = "sk-ant-..."');
    process.exit(1);
  }

  log('Browser starten…');
  const browser = await chromium.launch({ headless: false, slowMo: 200 });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page    = await context.newPage();

  const client = new Anthropic();

  const messages = [
    { role: 'user', content: 'Start nu de volledige test van de MAMA CMMS applicatie. Doorloop systematisch alle modules en schrijf aan het einde een compleet rapport.' }
  ];

  log(`Agent gestart — model: ${MODEL}`);
  log('De browser opent en de agent begint met testen…\n');

  // Sla tussentijds rapport op na elke iteratie
  function savePartialReport(label = 'tussentijds') {
    try {
      const report = extractReport(messages);
      if (!report.trim()) return;
      mkdirSync(dirname(REPORT_PATH), { recursive: true });
      writeFileSync(REPORT_PATH, report, 'utf8');
      log(`  Rapport opgeslagen (${label}): ${REPORT_PATH}`);
    } catch (e) { /* stille fout */ }
  }

  let iteration = 0;

  try {
    // Agentic loop
    while (true) {
      iteration++;
      log(`Iteratie ${iteration} — Claude denkt na…`);

      const response = await client.messages.create({
        model:      MODEL,
        max_tokens: MAX_TOKENS,
        system:     SYSTEM_PROMPT,
        tools:      TOOLS,
        messages,
      });

      // Voeg assistent-antwoord toe aan history
      messages.push({ role: 'assistant', content: response.content });

      const textBlocks = response.content.filter(b => b.type === 'text');
      if (textBlocks.length) {
        textBlocks.forEach(b => {
          const preview = b.text.substring(0, 120).replace(/\n/g, ' ');
          log(`  Agent: ${preview}${b.text.length > 120 ? '…' : ''}`);
        });
        savePartialReport(`iteratie ${iteration}`);
      }

      // Klaar?
      if (response.stop_reason === 'end_turn') {
        log('\nAgent klaar met testen.');
        break;
      }

      // Tool-calls verwerken
      const toolUses = response.content.filter(b => b.type === 'tool_use');
      if (!toolUses.length) break;

      const toolResults = [];
      for (const tu of toolUses) {
        log(`  Tool: ${tu.name}(${JSON.stringify(tu.input).substring(0, 80)})`);
        const rawContent = await executeTool(page, tu.name, tu.input);
        toolResults.push({
          type:        'tool_result',
          tool_use_id: tu.id,
          content:     sanitizeContent(rawContent),
        });
      }

      messages.push({ role: 'user', content: toolResults });
    }
  } catch (err) {
    log(`\nFout tijdens uitvoering: ${err.message}`);
    log('Gedeeltelijk rapport opslaan…');
    savePartialReport('na crash');
    await browser.close();
    process.exit(1);
  }

  savePartialReport('definitief');
  await browser.close();
  log('Klaar.');
}

main().catch(err => {
  console.error('Fatale fout:', err.message);
  process.exit(1);
});
