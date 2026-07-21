import { chromium } from 'playwright';

const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const page = await browser.newPage();
const errors = [];
page.on('pageerror', (err) => errors.push(String(err)));
page.on('console', (msg) => { if (msg.type() === 'error') errors.push(msg.text()); });

await page.goto('http://localhost:4173/', { waitUntil: 'networkidle' });
await page.waitForTimeout(500);

const title = await page.textContent('h1');
console.log('H1:', title);

await page.screenshot({ path: '/tmp/boleta.png' });

// navigate to chart tab
await page.click('text=Gráfico');
await page.waitForTimeout(800);
await page.screenshot({ path: '/tmp/grafico.png' });

// navigate to journal tab
await page.click('text=Diário');
await page.waitForTimeout(500);
await page.screenshot({ path: '/tmp/diario.png' });

console.log('Console/page errors:', JSON.stringify(errors, null, 2));

await browser.close();
