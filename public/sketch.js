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
      src: "/shaders/ak_colorcompress.glsl",
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

const CPGP_Clouds = [
   {
      name: "Clouds",
      src: "/shaders/Clouds.glsl",
      size: "screen",
      screen: true,
      channels: [],
      uniforms: {
         paramPos: { type: '2f', value: [0.5, 0.5] },
         paramSpeed: { type: '1f', value: 300.0 },
         paramProcedural: { type: '1i', value: 1 },
         camera_use: { type: '1i', value: 0 },
         camera_position: { type: '3f', value: [0.0, 0.0, 0.0] },
         camera_interest: { type: '3f', value: [0.0, 0.0, 0.0] },
         camera_roll: { type: '1f', value: 0.0 },
         camera_fov: { type: '1f', value: 45.0 },
      }
   }
];

const CPGP_Fireball = [
   {
      name: "Fireball",
      src: "/shaders/Fireball.glsl",
      size: "screen",
      screen: true,
      channels: [],
      uniforms: {
         paramFlameSpeed: { type: '1f', value: 50.0 },
      }
   }
];

const CPGP_Flame = [
   {
      name: "Flame",
      src: "/shaders/Flame.glsl",
      size: "screen",
      screen: true,
      channels: [],
      uniforms: {
         paramFlameSpeed: { type: '1f', value: 50.0 },
         paramFlameDirection: { type: '2f', value: [1.0, 1.0] },
         paramColor1: { type: '3f', value: [1.0, 0.5, 0.1] },
         paramColor2: { type: '3f', value: [1.0, 1.0, 0.5] },
      }
   }
];

const CPGP_FractalCell = [
   {
      name: "FractalCell",
      src: "/shaders/FractalCell.glsl",
      size: "screen",
      screen: true,
      channels: [
         { url: "/assets/Soft.png", wrap: "repeat", filter: "nearest", flipY: true },
      ],
      uniforms: {
         paramSpeed: { type: '1f', value: 50.0 },
         UseLigthModulation: { type: '1i', value: 0 },
      }
   }
];

const CPGP_PaleBlueDot = [
   {
      name: "PaleBlueDot",
      src: "/shaders/PaleBlueDot.glsl",
      size: "screen",
      screen: true,
      channels: [
         { url: "/assets/Soft.png", wrap: "repeat", filter: "nearest", flipY: true },
         { url: "/assets/cover.png", wrap: "repeat", filter: "nearest", flipY: true },
      ],
      uniforms: {
         paramSpeed: { type: '1f', value: 50.0 },
      }
   }
];

const CPGP_Sin = [
   {
      name: "Sin",
      src: "/shaders/Sin.glsl",
      size: "screen",
      screen: true,
      channels: [],
      uniforms: {
         paramSinSpeed: { type: '1f', value: 50.0 },
         paramSinSPosX: { type: '1f', value: 0.0 },
      }
   }
];

const CPGP_TextureVortex = [
   {
      name: "TextureVortex",
      src: "/shaders/TextureVortex.glsl",
      size: "screen",
      screen: true,
      channels: [
         { url: "/assets/0000.jpeg", wrap: "repeat", filter: "nearest", flipY: true },
      ],
      uniforms: {
         paramPos: { type: '2f', value: [0.5, 0.5] },
         paramSpeed: { type: '1f', value: 50.0 },
         paramWaveSize: { type: '1f', value: 2.0 },
      }
   }
];

const CPGP_ParticuleFractale = [
   {
      name: "ParticuleFractale",
      src: "/shaders/ParticuleFractale.glsl",
      size: "screen",
      screen: true,
      channels: [],
      uniforms: {
         paramSpeed: { type: '1f', value: 3.0 },
         paramWarp: { type: '1i', value: 0 },
      }
   }
];

const CPGP_BasicLensflare = [
   {
      name: "BasicLensflare",
      src: "/shaders/BasicLensflare.glsl",
      size: "screen",
      screen: true,
      channels: [
         { url: "/assets/Soft.png", wrap: "repeat", filter: "nearest", flipY: true },
      ],
      uniforms: {
         paramDirection: { type: '2f', value: [0.5, 0.5] },
         paramMove: { type: '1i', value: 1 },
         paramSpeed: { type: '1f', value: 50.0 },
      }
   }
];

const SHADER_CONFIGS = [
   { id: 'reverse', label: 'Reverse Grade', passes: AFX_ReverseGrade },
   { id: 'grade', label: 'Grade', passes: AFX_Grade },
   { id: 'despill', label: 'DeSpill', passes: AFX_DeSpill },
   { id: 'colorcompress', label: 'Color Compress', passes: AK_ColorCompress },
   { id: 'vibrance', label: 'Vibrance', passes: AK_Vibrance },
   { id: 'clouds', label: 'CPGP Clouds', passes: CPGP_Clouds },
   { id: 'fireball', label: 'CPGP Fireball', passes: CPGP_Fireball },
   { id: 'flame', label: 'CPGP Flame', passes: CPGP_Flame },
   { id: 'fractalcell', label: 'CPGP FractalCell', passes: CPGP_FractalCell },
   { id: 'palebluedot', label: 'CPGP Pale Blue Dot', passes: CPGP_PaleBlueDot },
   { id: 'sin', label: 'CPGP Sin', passes: CPGP_Sin },
   { id: 'texturevortex', label: 'CPGP Texture Vortex', passes: CPGP_TextureVortex },
   { id: 'particulefractale', label: 'CPGP Particule Fractale', passes: CPGP_ParticuleFractale },
   { id: 'basiclensflare', label: 'CPGP Basic Lensflare', passes: CPGP_BasicLensflare },
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
