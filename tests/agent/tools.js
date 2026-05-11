// Playwright tool-definities voor de CMMS AI-agent

export const TOOLS = [
  {
    name: 'navigate',
    description: 'Navigeer naar een URL in de browser.',
    input_schema: {
      type: 'object',
      properties: {
        url: { type: 'string', description: 'Volledige URL (bijv. http://localhost:3000/index.html)' },
      },
      required: ['url'],
    },
  },
  {
    name: 'screenshot',
    description: 'Maak een screenshot van de huidige pagina en bekijk de UI.',
    input_schema: {
      type: 'object',
      properties: {},
      required: [],
    },
  },
  {
    name: 'click',
    description: 'Klik op een element via CSS-selector of zichtbare tekst.',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector of tekst (bijv. "button:has-text(\'Nieuw\')"' },
      },
      required: ['selector'],
    },
  },
  {
    name: 'dblclick',
    description: 'Dubbelklik op een element (bijv. tabelrij om drawer te openen).',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector van het element' },
      },
      required: ['selector'],
    },
  },
  {
    name: 'fill',
    description: 'Typ tekst in een invoerveld.',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector van het input/textarea element' },
        value:    { type: 'string', description: 'De tekst om in te typen' },
      },
      required: ['selector', 'value'],
    },
  },
  {
    name: 'select',
    description: 'Selecteer een optie in een <select> dropdown.',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector van de <select>' },
        value:    { type: 'string', description: 'De waarde om te selecteren' },
      },
      required: ['selector', 'value'],
    },
  },
  {
    name: 'wait_for',
    description: 'Wacht tot een element zichtbaar is op de pagina.',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector om op te wachten' },
        timeout:  { type: 'number', description: 'Max wachttijd in ms (standaard 5000)' },
      },
      required: ['selector'],
    },
  },
  {
    name: 'get_text',
    description: 'Haal de zichtbare tekst op van elementen op de pagina.',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector (bijv. "tbody tr", ".kpi-value")' },
      },
      required: ['selector'],
    },
  },
  {
    name: 'evaluate',
    description: 'Voer JavaScript uit in de browser en geef het resultaat terug.',
    input_schema: {
      type: 'object',
      properties: {
        expression: { type: 'string', description: 'JavaScript expressie (bijv. "document.title")' },
      },
      required: ['expression'],
    },
  },
  {
    name: 'hover',
    description: 'Hover over een element (bijv. om tooltips of hover-states te testen).',
    input_schema: {
      type: 'object',
      properties: {
        selector: { type: 'string', description: 'CSS-selector van het element' },
      },
      required: ['selector'],
    },
  },
  {
    name: 'press_key',
    description: 'Druk op een toets (bijv. Escape om modals te sluiten).',
    input_schema: {
      type: 'object',
      properties: {
        key: { type: 'string', description: 'Toetsnaam (bijv. "Escape", "Enter", "Tab")' },
      },
      required: ['key'],
    },
  },
];

/**
 * Voert een tool-actie uit met Playwright en geeft het resultaat terug
 * als Anthropic tool_result content blocks.
 */
export async function executeTool(page, name, input) {
  try {
    switch (name) {
      case 'navigate': {
        await page.goto(input.url, { waitUntil: 'networkidle', timeout: 15000 });
        await page.waitForTimeout(1000);
        return [{ type: 'text', text: `Navigated to ${input.url}` }];
      }

      case 'screenshot': {
        const buf = await page.screenshot({ fullPage: false });
        return [
          { type: 'text', text: 'Screenshot genomen:' },
          { type: 'image', source: { type: 'base64', media_type: 'image/png', data: buf.toString('base64') } },
        ];
      }

      case 'click': {
        await page.click(input.selector, { timeout: 8000 });
        await page.waitForTimeout(600);
        return [{ type: 'text', text: `Clicked: ${input.selector}` }];
      }

      case 'dblclick': {
        await page.dblclick(input.selector, { timeout: 8000 });
        await page.waitForTimeout(800);
        return [{ type: 'text', text: `Double-clicked: ${input.selector}` }];
      }

      case 'fill': {
        await page.fill(input.selector, input.value, { timeout: 5000 });
        return [{ type: 'text', text: `Filled "${input.selector}" with "${input.value}"` }];
      }

      case 'select': {
        await page.selectOption(input.selector, input.value, { timeout: 5000 });
        return [{ type: 'text', text: `Selected "${input.value}" in ${input.selector}` }];
      }

      case 'wait_for': {
        await page.waitForSelector(input.selector, { timeout: input.timeout || 5000 });
        return [{ type: 'text', text: `Element zichtbaar: ${input.selector}` }];
      }

      case 'get_text': {
        const texts = await page.locator(input.selector).allTextContents();
        const result = texts.slice(0, 20).join('\n');
        return [{ type: 'text', text: result || '(geen tekst gevonden)' }];
      }

      case 'evaluate': {
        const result = await page.evaluate(input.expression);
        const str = JSON.stringify(result, null, 2);
        return [{ type: 'text', text: str !== undefined ? str : '(undefined)' }];
      }

      case 'hover': {
        await page.hover(input.selector, { timeout: 5000 });
        await page.waitForTimeout(400);
        return [{ type: 'text', text: `Hovering over: ${input.selector}` }];
      }

      case 'press_key': {
        await page.keyboard.press(input.key);
        await page.waitForTimeout(400);
        return [{ type: 'text', text: `Key pressed: ${input.key}` }];
      }

      default:
        return [{ type: 'text', text: `Onbekende tool: ${name}` }];
    }
  } catch (err) {
    return [{ type: 'text', text: `FOUT bij ${name}: ${err.message || String(err)}` }];
  }
}

// Zorgt dat alle text-blokken altijd een geldige niet-lege string hebben
export function sanitizeContent(blocks) {
  return blocks.map(b => {
    if (b.type === 'text') {
      return { ...b, text: (b.text != null && b.text !== '') ? String(b.text) : '(leeg)' };
    }
    return b;
  });
}
