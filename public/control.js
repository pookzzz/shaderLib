function vec3ToHex(v) {
  const to255 = (x) => Math.max(0, Math.min(255, Math.round(x * 255)));
  const toHex = (n) => n.toString(16).padStart(2, '0');
  const r = to255(v[0]);
  const g = to255(v[1]);
  const b = to255(v[2]);
  return '#' + toHex(r) + toHex(g) + toHex(b);
}

function hexToVec3(hex) {
  const h = hex.replace('#', '');
  if (h.length !== 6) return [0, 0, 0];
  const r = parseInt(h.slice(0, 2), 16) / 255;
  const g = parseInt(h.slice(2, 4), 16) / 255;
  const b = parseInt(h.slice(4, 6), 16) / 255;
  return [r, g, b];
}

const canvas = document.getElementById('glcanvas');
let canvasMode = 'window';
let imageSize = null;

function detectImageSize(passes) {
  for (const pass of passes) {
    if (pass.channels && pass.channels.length) {
      const ch = pass.channels.find(c => c.url);
      if (ch) {
        return new Promise(resolve => {
          const img = new Image();
          img.crossOrigin = 'anonymous';
          img.onload = () => resolve({ width: img.naturalWidth, height: img.naturalHeight });
          img.onerror = () => resolve(null);
          img.src = ch.url;
        });
      }
    }
  }
  return Promise.resolve(null);
}

function applyCanvasMode() {
  if (!canvas) return;
  if (canvasMode === 'window') {
    canvas.classList.add('canvas-window');
    canvas.classList.remove('canvas-image');
    canvas.style.width = '100%';
    canvas.style.height = '100%';
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  } else if (canvasMode === 'image' && imageSize) {
    canvas.classList.add('canvas-image');
    canvas.classList.remove('canvas-window');
    canvas.width = imageSize.width;
    canvas.height = imageSize.height;
    canvas.style.width = imageSize.width + 'px';
    canvas.style.height = imageSize.height + 'px';
  }
}

window.addEventListener('resize', () => {
  if (canvasMode === 'window') applyCanvasMode();
});

async function createSizeControls(passes) {
  const container = document.getElementById('controls');
  if (!container) return;
  const group = document.createElement('div');
  group.className = 'control-group';
  const hdr = document.createElement('label');
  hdr.textContent = 'Canvas Size';
  group.appendChild(hdr);
  const row = document.createElement('div');
  row.style.display = 'flex';
  row.style.gap = '10px';
  const win = document.createElement('input');
  win.type = 'radio'; win.name = 'canvas-mode'; win.id = 'canvas-mode-window'; win.checked = true;
  const winLbl = document.createElement('label'); winLbl.htmlFor = 'canvas-mode-window'; winLbl.textContent = 'Window';
  const img = document.createElement('input');
  img.type = 'radio'; img.name = 'canvas-mode'; img.id = 'canvas-mode-image';
  const imgLbl = document.createElement('label'); imgLbl.htmlFor = 'canvas-mode-image'; imgLbl.textContent = 'Image';
  row.appendChild(win); row.appendChild(winLbl); row.appendChild(img); row.appendChild(imgLbl);
  group.appendChild(row);
  container.insertBefore(group, container.firstChild);
  imageSize = await detectImageSize(passes);
  applyCanvasMode();
  win.onchange = () => { canvasMode = 'window'; applyCanvasMode(); };
  img.onchange = () => { canvasMode = 'image'; applyCanvasMode(); };
}

function clearControls() {
  const container = document.getElementById('controls');
  if (container) container.innerHTML = '';
}

function createShaderSelector(options, onChange) {
  const container = document.getElementById('controls');
  if (!container || !options || !options.length) return;

  const group = document.createElement('div');
  group.className = 'control-group';

  const label = document.createElement('label');
  label.textContent = 'Shader';
  group.appendChild(label);

  const select = document.createElement('select');
  select.style.width = '100%';

  options.forEach(opt => {
    const optionEl = document.createElement('option');
    optionEl.value = opt.id;
    optionEl.textContent = opt.label;
    if (opt.selected) optionEl.selected = true;
    select.appendChild(optionEl);
  });

  select.onchange = (e) => {
    if (onChange) onChange(e.target.value);
  };

  group.appendChild(select);
  container.insertBefore(group, container.firstChild);
}

async function createControls(passes) {
  const container = document.getElementById('controls');
  if (!container) return;

  await createSizeControls(passes);

  passes.forEach((pass, index) => {
    const uniforms = pass.uniforms;
    if (!uniforms) return;

    const group = document.createElement('div');
    group.className = 'pass-group';

    const title = document.createElement('h3');
    title.textContent = pass.name || `Pass ${index + 1}`;
    title.style.marginTop = '0';
    title.style.fontSize = '14px';
    title.style.borderBottom = '1px solid #666';
    title.style.paddingBottom = '5px';
    group.appendChild(title);

    for (const [key, uniform] of Object.entries(uniforms)) {
      const controlGroup = document.createElement('div');
      controlGroup.className = 'control-group';

      const label = document.createElement('label');
      label.textContent = key;
      controlGroup.appendChild(label);

      if (uniform.type === '1f') {
        const row = document.createElement('div');
        row.style.display = 'flex';
        row.style.alignItems = 'center';
        row.style.gap = '10px';

        const slider = document.createElement('input');
        slider.type = 'range';
        slider.step = '0.001';

        let val = uniform.value;
        let min = 0, max = 2;
        if (val < 0) min = val * 2;
        if (val > 2) max = val * 2;
        if (Math.abs(val) > 10) {
          min = 0; max = val * 2;
        }
        if (val < -10) {
          min = val * 2; max = 0;
        }

        slider.min = min;
        slider.max = max;
        slider.value = val;
        slider.style.flex = '1';

        const number = document.createElement('input');
        number.type = 'number';
        number.step = '0.001';
        number.value = val;
        number.style.width = '60px';

        const update = (v) => {
          const f = parseFloat(v);
          uniform.value = f;
          slider.value = f;
          number.value = f;
        };

        slider.oninput = (e) => update(e.target.value);
        number.oninput = (e) => update(e.target.value);

        row.appendChild(slider);
        row.appendChild(number);
        controlGroup.appendChild(row);

      } else if (uniform.type === '1i') {
        const input = document.createElement('input');
        input.type = 'number';
        input.step = '1';
        input.value = uniform.value;
        input.oninput = (e) => {
          uniform.value = parseInt(e.target.value, 10);
        };
        controlGroup.appendChild(input);

      } else if (uniform.type === '3f') {
        const row = document.createElement('div');
        row.className = 'vec3-container';

        const color = document.createElement('input');
        color.type = 'color';
        color.value = vec3ToHex(uniform.value);
        row.appendChild(color);

        const numberInputs = [];

        [0, 1, 2].forEach(i => {
          const input = document.createElement('input');
          input.type = 'number';
          input.step = '0.01';
          input.value = uniform.value[i];
          input.oninput = (e) => {
            const f = parseFloat(e.target.value);
            uniform.value[i] = f;
            color.value = vec3ToHex(uniform.value);
          };
          numberInputs.push(input);
          row.appendChild(input);
        });

        color.oninput = (e) => {
          const v = hexToVec3(e.target.value);
          uniform.value[0] = v[0];
          uniform.value[1] = v[1];
          uniform.value[2] = v[2];
          numberInputs.forEach((input, i) => {
            input.value = uniform.value[i].toFixed(2);
          });
        };

        controlGroup.appendChild(row);
      }

      group.appendChild(controlGroup);
    }
    container.appendChild(group);
  });
}