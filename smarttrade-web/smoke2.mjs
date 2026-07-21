import { chromium } from 'playwright';

const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', (err) => errors.push(String(err)));
page.on('console', (msg) => { if (msg.type() === 'error') errors.push(msg.text()); });

await page.goto('http://localhost:4173/', { waitUntil: 'networkidle' });

// Fill risk calc fields
await page.fill('input[type=number] >> nth=0', '20000'); // Entrada
await page.fill('input[type=number] >> nth=1', '19980'); // Stop
await page.fill('input[type=number] >> nth=2', '20040'); // Alvo
await page.waitForTimeout(300);
await page.screenshot({ path: '/tmp/boleta_calc.png' });

const riskText = await page.textContent('body');
console.log('Contains risk figures:', riskText.includes('40,00') || riskText.includes('40.00'));

// Go to journal and add entry using the same instrument/prices
await page.click('text=Diário');
await page.click('button[aria-label="Registrar operação"]');
await page.waitForTimeout(200);
const numberInputs = await page.$$('input[type=number]');
await numberInputs[0].fill('20000');
await numberInputs[1].fill('19980');
await numberInputs[2].fill('20040');
await page.screenshot({ path: '/tmp/diario_form.png' });
await page.click('button:has-text("Salvar no Diário")');
await page.waitForTimeout(400);
await page.screenshot({ path: '/tmp/diario_saved.png' });

console.log('Errors:', JSON.stringify(errors, null, 2));
await browser.close();
