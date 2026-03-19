# Design System Strategy: High-End Editorial Focus

## 1. Overview & Creative North Star: "The Kinetic Sanctuary"
The objective of this design system is to transform a standard utility into a high-end editorial experience. We are moving away from the "app-as-a-tool" aesthetic toward a "Kinetic Sanctuary"—a space that feels breathable, authoritative, and vibrantly alive. 

We break the traditional template look through **Intentional Asymmetry** and **Scale Contradiction**. By pairing massive, brutalist numerical displays with generous white space and delicate label text, we create a rhythmic visual tension. The interface should feel like a premium physical object—layered, deep, and meticulously curated. We use high-contrast primary accents to punctuate a calm, light-gray environment, ensuring that focus is not just a state of mind, but a visual destination.

---

## 2. Colors: Tonal Depth & Soul
The palette is anchored by the tension between the clinical `surface` (#f8faf9) and the electric energy of `primary_container` (#50e36b).

### The "No-Line" Rule
Sectioning must be achieved through background shifts, never 1px solid borders. For example, a session summary should sit on `surface_container_low` against a `surface` background. If the eye can perceive the edge through a color shift, a line is redundant and adds "visual noise."

### Surface Hierarchy & Nesting
Treat the UI as a stack of fine paper. 
*   **Base:** `surface` (#f8faf9)
*   **Layer 1 (Grouping):** `surface_container_low` (#f2f4f3)
*   **Layer 2 (Emphasis/Cards):** `surface_container_lowest` (#ffffff)
This nesting creates a soft, natural lift that guides the user’s eye without the need for aggressive shadows.

### Glass & Gradient Rule
To provide "soul," the main action buttons and active timer states should utilize a subtle linear gradient from `primary` (#006e26) to `primary_container` (#50e36b). For floating elements (like a timer overlay), use a **Glassmorphic** effect: a `surface` color at 70% opacity with a 20px backdrop-blur.

---

## 3. Typography: Editorial Authority
We utilize two distinct voices to create a sophisticated hierarchy.

*   **Display & Headlines (Space Grotesk):** This is our "Brutalist" voice. Used for the timer (`display-lg`) and section headers (`headline-md`). It is geometric, high-contrast, and commands attention.
*   **Body & Titles (Manrope):** This is our "Humanist" voice. Manrope provides superior legibility for settings, history logs, and labels. It balances the sharpness of Space Grotesk with a modern, approachable rhythm.

**Scale Philosophy:** The leap from `label-sm` (0.6875rem) to `display-lg` (3.5rem) is intentional. This extreme variance creates the "Editorial" feel, emphasizing that the time remaining is the only thing that truly matters.

---

## 4. Elevation & Depth: Tonal Layering
We reject the standard Material drop-shadow. Depth is a matter of light and material, not black ink.

*   **The Layering Principle:** Depth is achieved by stacking. A `surface_container_lowest` card placed on `surface_container` creates an "elevated" feel through contrast alone.
*   **Ambient Shadows:** Where floating is required (e.g., the bottom tab bar), use a shadow color tinted with the `on_surface` value at 4% opacity, with a blur radius of 32px. It should feel like a soft glow, not a hard edge.
*   **The "Ghost Border" Fallback:** If accessibility requires a border, use `outline_variant` (#bccbb8) at 15% opacity. It should be barely perceptible—a "ghost" of a container.

---

## 5. Components

### The Timer Display
*   **Token:** `display-lg` / `on_secondary_fixed` (#171b26).
*   **Styling:** No containers. The numbers should float centered in the upper third of the screen, utilizing `spacing.20` as top padding to create an editorial "header" feel.

### Primary Action Buttons
*   **Rounding:** `full` (9999px) for a pill-shaped, modern feel.
*   **Color:** Gradient of `primary` to `primary_container`.
*   **Interaction:** On press, scale down to 96% to simulate physical depth.
*   **Shadow:** Use a `primary_container` tinted shadow at 10% opacity for a "neon" lift effect.

### Secondary Buttons (Outline Style)
*   **Styling:** Use the "Ghost Border" at 20% opacity. Text should be `secondary` (#5a5e6a). Avoid solid fills to maintain a light, airy aesthetic.

### Tab Bar Navigation
*   **Surface:** `surface_container_highest` with 80% opacity and `backdrop-blur`.
*   **Indicator:** A small 4px dot in `primary` below the active icon, rather than a full block highlight.
*   **Height:** Use `spacing.16` for a tall, premium feel.

### Input Fields
*   **Style:** Minimalist. No box. Only a bottom "Ghost Border" that transitions to 2px `primary` on focus.
*   **Typography:** Labels must be `label-md` in `on_surface_variant`, positioned above the input.

---

## 6. Do's and Don'ts

### Do
*   **Do** use `spacing.12` and `spacing.16` to create vast "voids" of white space. It signals luxury and focus.
*   **Do** use `primary_fixed_dim` (#4ee16a) for success states and progress bars to maintain high-contrast vibrancy.
*   **Do** center-align the primary timer elements to maintain a formal, symmetric balance within the overall asymmetric layout.

### Don't
*   **Don't** use 1px solid black or dark grey borders. It breaks the "Kinetic Sanctuary" immersion.
*   **Don't** crowd the bottom tab bar. If an icon doesn't fit with `spacing.4` between elements, move it to a "More" menu.
*   **Don't** use standard "drop shadows." If it looks like a default plugin setting, it’s too heavy.
*   **Don't** use dividers in lists. Use `surface-container` color shifts or simple vertical padding (`spacing.6`).