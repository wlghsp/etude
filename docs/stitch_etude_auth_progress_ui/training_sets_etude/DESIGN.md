---
name: Etude Internal Training Platform
colors:
  surface: '#141313'
  surface-dim: '#141313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2b2a2a'
  surface-container-highest: '#353434'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c4c7c7'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8e9192'
  outline-variant: '#444748'
  surface-tint: '#c8c6c5'
  primary: '#c8c6c5'
  on-primary: '#313030'
  primary-container: '#111111'
  on-primary-container: '#7e7c7c'
  inverse-primary: '#5f5e5e'
  secondary: '#c8c6c5'
  on-secondary: '#313030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#cac6c3'
  on-tertiary: '#32302f'
  tertiary-container: '#121110'
  on-tertiary-container: '#7f7c7a'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474646'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#e6e1df'
  tertiary-fixed-dim: '#cac6c3'
  on-tertiary-fixed: '#1d1b1a'
  on-tertiary-fixed-variant: '#484645'
  background: '#141313'
  on-background: '#e5e2e1'
  surface-variant: '#353434'
typography:
  headline-lg:
    fontFamily: JetBrains Mono
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: JetBrains Mono
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: JetBrains Mono
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  code-sm:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-page: 24px
  container-max: 1280px
---

## Brand & Style

This design system is built for a high-performance technical environment, drawing inspiration from professional developer tools like VS Code and Linear. The aesthetic is **Minimalist-Technical**, prioritizing information density, clarity, and a "tool-not-toy" philosophy. 

The UI should evoke a sense of focus and efficiency. It avoids decorative elements in favor of functional structure, utilizing a dark-mode first approach that reduces eye strain during long training sessions. The emotional response is one of competence, precision, and systematic learning.

## Colors

The palette is anchored in a deep, neutral grayscale to provide a stable foundation for technical content. 

- **Primary Dark (#111111):** Used for the main application canvas and terminal backgrounds.
- **Surface (#1a1a1a):** Used for sidebars, cards, and elevated containers to create subtle depth without shadows.
- **Terminal Green (#22c55e):** The primary success indicator and accent for "active" states, mimicking a healthy CLI output.
- **Action Blue (#3b82f6):** Reserved for primary interactive elements and focus states.
- **Borders (#333333):** Used consistently for structural separation to maintain a "blueprint" feel.

## Typography

This design system uses **JetBrains Mono** exclusively to maintain a cohesive developer-centric environment. The monospace rhythm ensures that documentation, terminal outputs, and UI labels share a consistent vertical and horizontal cadence.

- Use `headline-lg` for module titles.
- Use `body-md` for standard instructional text.
- Use `label-caps` for metadata, status tags, and sidebar category headers.
- Maintain a strict 4px baseline grid to ensure alignment across different font sizes.

## Layout & Spacing

The layout follows a **Fixed Grid** model for documentation and a **Fluid-Shell** model for the workspace. 

- **Workspace:** A 3-column layout is standard: Navigator (Left, 240px), Editor/Content (Center, flexible), and Inspector/Terminal (Right or Bottom, flexible).
- **Grid:** Use a 12-column system for dashboard views with 16px gutters.
- **Rhythm:** All margins and paddings must be multiples of 4px. Use 16px for most container padding and 8px for internal element grouping.

## Elevation & Depth

In this design system, depth is communicated through **Tonal Layers** and **1px Borders** rather than shadows. 

- **Level 0 (#111111):** The base background.
- **Level 1 (#1a1a1a):** Inset or raised components like sidebars, code blocks, and card surfaces.
- **Borders:** Every interactive or distinct area is defined by a `1px solid #333333` border. 
- **Focus:** Active states should use a `1px solid #3b82f6` border or a subtle `22c55e` left-border accent for list items.
- Avoid all box-shadows to keep the interface looking sharp and digital.

## Shapes

The shape language is **Rectilinear**. All components use a minimal `4px` (0.25rem) radius to prevent a "harsh" look while maintaining a professional, tool-like appearance. 

- Large containers (Cards, Modals) use `rounded-lg` (8px).
- Buttons, inputs, and tags use the base `rounded` (4px).
- Status indicators (dots) are the only fully circular elements.

## Components

- **Buttons:** Use a "Terminal Style." Default buttons are ghost-style with a #333 border. Primary buttons use a solid #3b82f6 with #f0f0f0 text. Success/Run buttons use a #22c55e border and text.
- **Input Fields:** Background #111 (darker than surface), 1px #333 border, no glow on focus—only a color change of the border to #3b82f6.
- **Chips/Tags:** Small, monospace, with a #1a1a1a background and 1px border. Used for Docker image tags, k8s namespaces, etc.
- **Progress Bars:** Thin (4px height), using #333 for the track and #22c55e for the fill. No rounded ends (sharp vertical caps).
- **Code Blocks:** Background #111, subtle padding (12px), and a "Copy" button that only appears on hover.
- **Cards:** No shadows. Defined by a 1px #333 border and #1a1a1a background. Header sections within cards should have a bottom-border of 1px #333.