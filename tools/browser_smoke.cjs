// Optional visual check: npm install --prefix build/browser-qa playwright
// Serve `flutter build web --no-web-resources-cdn` output at localhost:7357.
// Uses installed Chrome headlessly; never launches Android Studio/an emulator.
const path = require('node:path');
const fs = require('node:fs/promises');
const { chromium } = require(path.join(__dirname, '..', 'build', 'browser-qa', 'node_modules', 'playwright'));

(async () => {
  const output = path.join(__dirname, '..', 'screenshots');
  await fs.mkdir(output, { recursive: true });
  const browser = await chromium.launch({ channel: 'chrome', headless: true,
    args: ['--disable-gpu', '--enable-unsafe-swiftshader'] });
  let page;
  try {
    const context = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1 });
    page = await context.newPage();
    const errors = [];
    const external = new Set();
    let stage = 'startup';
    page.on('pageerror', error => errors.push(String(error)));
    page.on('response', response => {
      if (response.status() >= 400) errors.push('HTTP ' + response.status() + ': ' + response.url());
    });
    page.on('console', message => {
      if (message.type() === 'warning' || message.type() === 'error') console.log('Browser: ' + message.text());
    });
    page.on('request', request => {
      if (!request.url().startsWith('http://127.0.0.1:7357') && /^https?:/.test(request.url())) {
        external.add(request.url());
        console.log('External request during ' + stage + ': ' + request.url());
      }
    });
    await page.goto('http://127.0.0.1:7357', { waitUntil: 'networkidle' });
    await page.locator('flt-semantics-placeholder').waitFor({ state: 'attached' });
    await page.locator('flt-semantics-placeholder').evaluate(element => element.click());
    const play = page.getByRole('button', { name: /Play · Easy/ });
    await play.waitFor();
    await page.waitForTimeout(1500);
    await page.screenshot({ path: path.join(output, 'menu.png') });
    stage = 'gameplay';
    await play.click();
    await page.waitForTimeout(750);
    await page.screenshot({ path: path.join(output, 'gameplay.png') });
    await page.getByRole('button', { name: 'Pause game' }).click();
    await page.mouse.move(2, 2);
    await page.waitForTimeout(200);
    stage = 'pause';
    await page.getByRole('button', { name: 'Keep going', exact: true }).waitFor();
    await page.screenshot({ path: path.join(output, 'paused.png') });
    await page.getByRole('button', { name: 'Settings', exact: true }).click();
    stage = 'settings';
    await page.getByRole('button', { name: 'Done', exact: true }).waitFor();
    await page.screenshot({ path: path.join(output, 'settings.png') });
    await page.getByRole('button', { name: 'Done', exact: true }).click();
    await page.getByRole('button', { name: 'Keep going', exact: true }).click();
    stage = 'results';
    await page.getByRole('button', { name: 'Try again', exact: true }).waitFor({ timeout: 15000 });
    await page.screenshot({ path: path.join(output, 'results.png') });
    await page.getByRole('button', { name: 'Back home', exact: true }).click();
    stage = 'privacy';
    await page.getByRole('button', { name: 'For grown-ups', exact: true }).click();
    await page.mouse.move(195, 450);
    await page.mouse.wheel(0, 1800);
    const policyResponse = page.waitForResponse(response =>
      response.url().includes('/docs/PRIVACY_POLICY.md') && response.status() === 200);
    await page.getByRole('button', { name: 'Full privacy policy', exact: true }).click();
    const policy = await (await policyResponse).text();
    if (!policy.includes('muzammiljawad6@gmail.com') || !policy.includes('November 1, 2026')) {
      throw new Error('Bundled policy contact/effective date is incorrect');
    }
    await page.getByRole('button', { name: 'Back', exact: true }).waitFor();
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'privacy.png') });
    await page.getByRole('button', { name: 'Back', exact: true }).click();
    await page.getByRole('button', { name: 'Done', exact: true }).click();
    stage = 'reload';
    await page.reload({ waitUntil: 'networkidle' });
    const placeholder = page.locator('flt-semantics-placeholder');
    if (await placeholder.count()) await placeholder.evaluate(element => element.click());
    await page.getByRole('button', { name: /Play · Easy/ }).waitFor();
    const savedProgress = await page.evaluate(() => Object.entries(localStorage)
      .find(([key]) => key.includes('little_dino.progress.v1'))?.[1]);
    let saved = JSON.parse(savedProgress || 'null');
    if (typeof saved === 'string') saved = JSON.parse(saved);
    if (!saved || saved.best_easy <= 0) throw new Error('Best score did not persist after reload');
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'reloaded.png') });
    await page.setViewportSize({ width: 320, height: 568 });
    await page.screenshot({ path: path.join(output, 'small-screen.png') });
    const result = { errors, externalRequests: [...external], checks: [
      'menu', 'start', 'gameplay', 'pause', 'settings', 'resume', 'collision/results',
      'home', 'complete bundled privacy policy/contact',
      'stored best-score persistence after page reload', 'small screen' ],
      savedBestScore: saved.best_easy };
    await fs.writeFile(path.join(output, 'browser-results.json'), JSON.stringify(result, null, 2));
    console.log(JSON.stringify(result, null, 2));
    if (errors.length || external.size) process.exitCode = 1;
  } catch (error) {
    if (page) {
      await page.screenshot({ path: path.join(output, 'failure.png') });
      await fs.writeFile(path.join(__dirname, '..', 'build', 'browser-qa', 'failure.html'), await page.content());
      console.log(await page.locator('[aria-label]').evaluateAll(elements => elements.map(element => element.getAttribute('aria-label'))));
    }
    throw error;
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
