const AFX_DeSpill = [
  {
    name: "AFX_DeSpill",
    src: "/shaders/DeSpill.glsl",
    size: "screen",
    screen: true,
    channels: [
      {
        url: "/assets/0000.jpeg",
        wrap: "repeat",
        filter: "nearest",
        flipY: true
      },
    ],
    uniforms: {
      type: { type: '1i', value: 2 },
      amount: { type: '1f', value: 100.0 }
    }
  }
];
// startShaderMate(AFX_DeSpill);

const AFX_Grade = [
  {
    name: "AFX_Grade",
    src: "/shaders/Grade.glsl",
    size: "screen",
    screen: true,
    channels: [
      {
        url: "/assets/0000.jpeg",
        wrap: "repeat",
        filter: "nearest",
        flipY: true
      },
      {
        url: "/assets/Soft.png",
        wrap: "repeat",
        filter: "nearest",
        flipY: true
      },
    ],
    uniforms: {
      premultiplied: { type: '1i', value: 0 },
      temp: { type: '1f', value: 0.1 },
      tint: { type: '1f', value: 1.0 },
      saturation: { type: '1f', value: 1. },
      offset: { type: '1f', value: 0.0 },
      gamma: { type: '1f', value: 1. },
      multiply: { type: '1f', value: 1.0 },
      s_whitePoint: { type: '3f', value: [0.5, 0.5, 0.1] },
      RGBOffset: { type: '3f', value: [0.0, 0.0, 0.0] },
      RGBGamma: { type: '3f', value: [1., 1., 1.] },
      RGBMultiply: { type: '3f', value: [1.0, 1.0, 1.0] },
    }
  }
];

const AFX_ReverseGrade = [
  {
    name: "AFX_ReverseGrade",
    src: "/shaders/ReverseGrade.glsl",
    size: "screen",
    screen: true,
    channels: [
      {
        url: "/assets/0000.jpeg",
        wrap: "repeat",
        filter: "nearest",
        flipY: true
      },
      {
        url: "/assets/0000.jpeg",
        wrap: "repeat",
        filter: "nearest",
        flipY: true
      },
      {
        url: "/assets/Soft.png",
        wrap: "repeat",
        filter: "nearest",
        flipY: true
      },
    ],
    uniforms: {
      premultiplied: { type: '1i', value: 0 },
      s_whitePoint: { type: '3f', value: [1.0, 1.0, 1.0] },
      s_blackPoint: { type: '3f', value: [0.0, 0.0, 0.0] },
      t_whitePoint: { type: '3f', value: [1.0, 1.0, 1.0] },
      t_blackPoint: { type: '3f', value: [0.0, 0.0, 0.0] },
    }
  }
];

const AK_ColorCompress = [
  {
    name: "AK_ColorCompress",
    src: "/shaders/ColorCompress.glsl",
    size: "screen",
    screen: true,
    channels: [
      { url: "/assets/0000.jpeg", wrap: "repeat", filter: "nearest", flipY: true },
      { url: "/assets/Soft.png", wrap: "repeat", filter: "nearest", flipY: true }, // as matte
    ],
    uniforms: {
      color_target: { type: '3f', value: [1.0, 0.5, 0.2] },
      hue_strength: { type: '1f', value: 50.0 },
      sat_strength: { type: '1f', value: 50.0 },
      lum_strength: { type: '1f', value: 50.0 },
      strength_curve: { type: '1i', value: 0 },
    }
  }
];

const AK_Vibrance = [
  {
    name: "AK_Vibrance",
    src: "/shaders/Vibrance.glsl",
    size: "screen",
    screen: true,
    channels: [
      { url: "/assets/0000.jpeg", wrap: "repeat", filter: "nearest", flipY: true },
      { url: "/assets/Soft.png", wrap: "repeat", filter: "nearest", flipY: true },
    ],
    uniforms: {
      strength: { type: '1f', value: 1.0 },
    }
  }
];

const SHADER_CONFIGS = [
  { id: 'reverse', label: 'Reverse Grade', passes: AFX_ReverseGrade },
  { id: 'grade', label: 'Grade', passes: AFX_Grade },
  { id: 'despill', label: 'DeSpill', passes: AFX_DeSpill },
  { id: 'colorcompress', label: 'Color Compress', passes: AK_ColorCompress },
  { id: 'vibrance', label: 'Vibrance', passes: AK_Vibrance },
];

let currentShaderId = 'reverse';

function loadShader(id) {
  const cfg = SHADER_CONFIGS.find(s => s.id === id);
  if (!cfg) return;
  currentShaderId = id;

  if (typeof clearControls === 'function') {
    clearControls();
  }

  startShaderMate(cfg.passes);

  if (typeof createControls === 'function') {
    createControls(cfg.passes);
  }

  if (typeof createShaderSelector === 'function') {
    createShaderSelector(
      SHADER_CONFIGS.map(s => ({
        id: s.id,
        label: s.label,
        selected: s.id === currentShaderId,
      })),
      loadShader
    );
  }
}

loadShader(currentShaderId);
