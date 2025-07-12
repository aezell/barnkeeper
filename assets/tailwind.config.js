// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/barnkeeper_web.ex",
    "../lib/barnkeeper_web/**/*.*ex"
  ],
  daisyui: {
    themes: [
      {
        barnkeeper: {
          "primary": "#8B4513",        // Saddle brown - warm, earthy
          "primary-content": "#FFFFFF",
          "secondary": "#D2691E",      // Chocolate - complementary brown
          "secondary-content": "#FFFFFF",
          "accent": "#DAA520",         // Goldenrod - hint of luxury
          "accent-content": "#000000",
          "neutral": "#4A4A4A",        // Charcoal gray
          "neutral-content": "#FFFFFF",
          "base-100": "#FEFEFE",       // Off-white background
          "base-200": "#F8F6F3",       // Warm cream
          "base-300": "#F0EDE8",       // Light beige
          "base-content": "#2C2C2C",   // Dark gray text
          "info": "#3ABFF8",
          "info-content": "#FFFFFF",
          "success": "#36D399",
          "success-content": "#FFFFFF",
          "warning": "#FBBD23",
          "warning-content": "#000000",
          "error": "#F87272",
          "error-content": "#FFFFFF",
        },
      },
    ],
  },
  theme: {
    extend: {
      colors: {
        brand: "#8B4513",
        "barn-brown": "#8B4513",
        "leather": "#D2691E",
        "hay": "#DAA520",
        "cream": "#F8F6F3",
        "parchment": "#F0EDE8",
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        display: ['Playfair Display', 'serif'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      backgroundImage: {
        'gradient-barn': 'linear-gradient(135deg, #F8F6F3 0%, #F0EDE8 50%, #E8E2DB 100%)',
        'gradient-hero': 'linear-gradient(135deg, #8B4513 0%, #A0522D 50%, #CD853F 100%)',
      },
      boxShadow: {
        'barn': '0 4px 20px -2px rgba(139, 69, 19, 0.1)',
        'warm': '0 8px 30px -4px rgba(139, 69, 19, 0.2)',
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("daisyui"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
