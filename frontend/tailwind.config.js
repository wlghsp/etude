/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        'surface': '#141313',
        'surface-container': '#201f1f',
        'surface-container-low': '#1c1b1b',
        'surface-container-high': '#2b2a2a',
        'surface-container-highest': '#353434',
        'surface-container-lowest': '#0e0e0e',
        'surface-variant': '#353434',
        'on-surface': '#e5e2e1',
        'on-surface-variant': '#c4c7c7',
        'primary': '#c8c6c5',
        'on-primary': '#313030',
        'primary-container': '#111111',
        'on-primary-container': '#7e7c7c',
        'primary-fixed': '#e5e2e1',
        'secondary': '#c8c6c5',
        'secondary-container': '#474746',
        'on-secondary': '#313030',
        'outline': '#8e9192',
        'outline-variant': '#444748',
        'error': '#ffb4ab',
        'error-container': '#93000a',
        'success': '#22c55e',
        'info': '#3b82f6',
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        'headline-lg': ['24px', { lineHeight: '32px', letterSpacing: '-0.02em', fontWeight: '700' }],
        'headline-md': ['20px', { lineHeight: '28px', letterSpacing: '-0.01em', fontWeight: '600' }],
        'body-lg': ['16px', { lineHeight: '24px', fontWeight: '400' }],
        'body-md': ['14px', { lineHeight: '20px', fontWeight: '400' }],
        'code-sm': ['13px', { lineHeight: '18px', fontWeight: '400' }],
        'label-caps': ['11px', { lineHeight: '16px', letterSpacing: '0.05em', fontWeight: '600' }],
      },
      spacing: {
        'gutter': '16px',
        'margin-page': '24px',
      },
    },
  },
  plugins: [],
}

