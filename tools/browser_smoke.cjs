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
    async function tapScrolling(name) {
      await page.mouse.move(195, 440);
      await page.mouse.wheel(0, -6000);
      await page.waitForTimeout(120);
      for (let attempt = 0; attempt < 16; attempt++) {
        const button = page.getByRole('button', { name, exact: typeof name === 'string' });
        if (await button.isVisible()) { await button.click(); return; }
        await page.mouse.wheel(0, 240);
        await page.waitForTimeout(100);
      }
      throw new Error('Could not scroll to button: ' + name);
    }
    async function goBack() {
      const back = page.getByRole('button', { name: 'Back', exact: true });
      await back.waitFor({ state: 'visible' });
      // Dispatch the accessibility action directly: outgoing Flutter route
      // nodes can detach while Playwright is doing pointer hit-test retries.
      await back.evaluate(element => element.click());
      await page.waitForTimeout(400);
    }
    async function enableSemantics() {
      const node = page.locator('flt-semantics-placeholder');
      if (await node.count()) await node.evaluate(element => element.click());
    }
    const animationChecks = [];
    async function checkAnimation(name) {
      await tapScrolling('Run preview');
      await page.getByRole('button', { name: 'Stop running', exact: true }).waitFor();
      await page.mouse.move(2, 2);
      await page.waitForTimeout(250);
      const clip = { x: 55, y: 80, width: 280, height: 240 };
      const first = await page.screenshot({ clip,
        path: path.join(output, name.toLowerCase() + '-run-a.png') });
      await page.waitForTimeout(130);
      const second = await page.screenshot({ clip,
        path: path.join(output, name.toLowerCase() + '-run-b.png') });
      if (first.equals(second)) throw new Error(name + ' running preview is frozen');
      await tapScrolling('Try a hop');
      await page.waitForTimeout(200);
      await page.screenshot({ path: path.join(output, name.toLowerCase() + '-jump.png') });
      await page.waitForTimeout(650);
      await tapScrolling('Stop running');
      await page.getByRole('button', { name: 'Run preview', exact: true }).waitFor();
      animationChecks.push(name + ': changing run frames, jump and stop');
    }
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
    await page.getByRole('button', { name: 'Try a hop with Sprout', exact: true }).click();
    await page.waitForTimeout(200);
    await page.screenshot({ path: path.join(output, 'home-hop.png') });
    await page.waitForTimeout(650);
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
    await tapScrolling('For grown-ups');
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
    await goBack();
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
    // Test fixture only: seed local storage to exercise a purchase without hours
    // of automated play. No debug coin grant exists in the production UI.
    await page.evaluate(() => {
      const key = Object.keys(localStorage).find(key => key.includes('little_dino.progress.v1'));
      let data = JSON.parse(localStorage.getItem(key));
      const wrapped = typeof data === 'string';
      if (wrapped) data = JSON.parse(data);
      data.coins = 1200;
      localStorage.setItem(key, JSON.stringify(wrapped ? JSON.stringify(data) : data));
    });
    await page.reload({ waitUntil: 'networkidle' }); await enableSemantics();
    stage = 'shop';
    await tapScrolling('Dino Shop');
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'shop.png') });
    await tapScrolling('Preview Sprout');
    await checkAnimation('Sprout');
    await goBack();
    await tapScrolling('Preview Bramble');
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'dino-preview.png') });
    await checkAnimation('Bramble');
    await tapScrolling('Buy for 1,000 gold');
    await page.getByRole('button', { name: 'Buy and use', exact: true }).click();
    await page.getByRole('button', { name: 'Equipped', exact: true }).waitFor();
    await goBack();
    for (const name of ['Sunny', 'Nova']) {
      await tapScrolling('Preview ' + name);
      await page.waitForTimeout(500);
      await page.screenshot({ path: path.join(output, name.toLowerCase() + '-preview.png') });
      await checkAnimation(name);
      await goBack();
    }
    await goBack();
    stage = 'gifts';
    await tapScrolling(/Weekly Gifts/);
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'weekly-gifts.png') });
    await page.mouse.move(195, 480);
    await page.mouse.wheel(0, 600);
    await page.waitForTimeout(300);
    await page.screenshot({ path: path.join(output, 'weekly-trail.png') });
    await tapScrolling('Claim 100 gold');
    await page.getByRole('button', { name: 'Gift claimed for today', exact: true }).waitFor();
    await page.mouse.wheel(0, -6000);
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'weekly-gifts-claimed.png') });
    await goBack();
    await tapScrolling('My Dinosaurs');
    await tapScrolling('Preview Bramble');
    await page.getByRole('button', { name: 'Equipped', exact: true }).waitFor();
    await goBack();
    await goBack();
    await page.reload({ waitUntil: 'networkidle' }); await enableSemantics();
    let finalProgress = await page.evaluate(() => Object.entries(localStorage)
      .find(([key]) => key.includes('little_dino.progress.v1'))[1]);
    finalProgress = JSON.parse(finalProgress);
    if (typeof finalProgress === 'string') finalProgress = JSON.parse(finalProgress);
    if (finalProgress.coins !== 300 || finalProgress.selectedDino !== 'bramble' ||
        !finalProgress.owned.includes('bramble') || finalProgress.nextGift !== 1) {
      throw new Error('Purchase, selection or gift did not persist correctly');
    }
    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(output, 'reloaded.png') });
    await page.setViewportSize({ width: 320, height: 568 });
    await page.screenshot({ path: path.join(output, 'small-screen.png') });
    const result = { errors, externalRequests: [...external], animationChecks, checks: [
      'menu', 'start', 'gameplay', 'pause', 'settings', 'resume', 'collision/results',
      'interactive home hop',
      'home', 'complete bundled privacy policy/contact',
      'stored best-score persistence after page reload', 'small screen' ],
      savedBestScore: saved.best_easy, shopFixtureStartingGold: 1200,
      economyChecks: ['preview', 'confirmed 1000-coin purchase', 'equipped ownership',
        'collection', '100-coin daily claim', 'purchase/gift/selection reload'], finalGold: finalProgress.coins };
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
