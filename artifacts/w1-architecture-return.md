# SLP V5.1 Return Packet: System Architecture, Core Taxonomy & System-Level Docs
**Work ID:** `w1`  
**State:** `RETURNED`  
**Author:** `PeerArchitectureTaxonomy`  
**Date:** 2026-09-24  
**Target:** Root Core Docs, Design System & Token Architecture, Cross-App Boundaries & Invariants  

---

## 1. Executive Summary & Diagnostic Findings

Inspection of `.knowns/docs/` and the codebase reveals an architectural disconnect between agent workflows (such as `kn-init`) and current doc placement:
1. **Critical Tooling Gap at Root**: `kn-init` actively issues lookups for `README`, `ARCHITECTURE`, and `CONVENTIONS` (`skill://kn-init:27-31`). Because all existing 12 docs are located under `.knowns/docs/constellation/`, `kn-init` encounters `Doc not found` errors (`README not found`, `ARCHITECTURE not found`, `CONVENTIONS not found`), causing session initialization warnings and loss of system-level orientation.
2. **Visual & Typographic Identity Isolation**: The 4 prototypes (`designs/quire`, `designs/dream-journal`, `designs/after-midnight`, `designs/astraea`) employ strictly non-interchangeable typographic pairings, differing surface material paradigms (tactile paper, obsidian/5-layer veil glass, nocturnal starfield void, midnight violet velvet), and autonomous token namespaces.
3. **Anti-Merge & Calm Computing Invariants**: In accordance with `s-01`, `c-90`, and `c-91`, the applications share macro-architectural tenets (Zero Backend / Local-First, Calm Computing / Anti-Retention, Viewport Contract `390x844`), while maintaining strict isolation of UI tokens, state machines, and styling.

---

## 2. Missing Core Docs Analysis (`.knowns/docs/` Root)

### 2.1 The `kn-init` Invariant
The standard Knowns session initialization skill (`skill://kn-init`) executes:
```json
mcp__knowns__get_doc({ "path": "README", "smart": true })
mcp__knowns__get_doc({ "path": "ARCHITECTURE", "smart": true })
mcp__knowns__get_doc({ "path": "CONVENTIONS", "smart": true })
```
When these files are missing at `.knowns/docs/`, agents report risk flags (`missing docs, unclear conventions`) and fall back to incomplete codebase heuristics.

### 2.2 Root Documentation Triad Design
To resolve this without violating `S-01` (which mandates docs live in `.knowns/docs` and forbids phantom schemas):
1. **`README.md` (`path: "README"` at `.knowns/docs/README.md`)**:
   - **Role**: Portfolio orientation, entry point for human engineers and automated agents.
   - **Contents**: High-level portfolio thesis (Constellation as 4 autonomous calm mobile prototypes), catalog of prototypes, folder taxonomy map (`constellation/`, `architecture/`, `patterns/`, `guides/`), agent quickstart guide, and core boundaries.
2. **`ARCHITECTURE.md` (`path: "ARCHITECTURE"` at `.knowns/docs/ARCHITECTURE.md`)**:
   - **Role**: System-level macro-architecture, technical invariants, and runtime execution boundaries.
   - **Contents**: Local-First / Zero-Backend invariant, 4-domain separation matrix, Calm Computing & anti-retention mechanics, viewport framing contract (`390x844` / `r:44px`), prototype-to-engineering handoff boundary, and architectural risk ledger.
3. **`CONVENTIONS.md` (`path: "CONVENTIONS"` at `.knowns/docs/CONVENTIONS.md`)**:
   - **Role**: Technical standards, documentation protocols, and operational safety.
   - **Contents**: S-01 Observe-Only Anti-Minting contract (zero phantom code, zero fake REST/GraphQL/SQL schemas), Knowns metadata frontmatter standards, UTF-8 encoding requirements on Windows (Memory `w6kiug`), git-submodule immutability (`designs/*` read-only), and validation protocols (`knowns validate`).

---

## 3. Foundational Design System & Token Architecture Analysis

A rigorous, byte-level analysis of the 4 prototype files establishes the following ground truth:

### 3.1 The 4 Typography Pairs (Deliberate Independence)
Each prototype implements an autonomous, non-interchangeable typographic pairing tuned to its emotional intent:

| Application | Primary Display / Narrative Font | Technical / UI / Data Font | Codebase File & Anchors | Rationale & Mechanical Behavior |
|---|---|---|---|---|
| **Quire** | `Newsreader` (optical size 6..72, weights 300–600, roman & italic) | `JetBrains Mono` (weights 400–600) | `designs/quire/prototype.html#600B:14, 23-25` | Editorial publishing warmth. Newsreader scales via `.ts-1` (-1px) and `.ts-3` (+2px). JetBrains Mono formats mechanical timestamps ("14:23"), word counters ("420 TỪ"), and circle stats. |
| **Dream Journal** | `Cormorant Garamond` (weights 400–600, italic) | `Be Vietnam Pro` (weights 300–600) | `designs/dream-journal/index.html#9FC4:10, 58-61` | Cormorant delivers lyrical, classical oneiric elegance. Be Vietnam Pro provides pristine legibility for complex Vietnamese diacritics and accent tone marks in introspective dream records. |
| **After Midnight** | `Instrument Serif` (regular & italic) | `IBM Plex Sans` + `IBM Plex Mono` | `designs/after-midnight/v1 after midnight - interactive prototype.html#19F5:47-50` | Instrument Serif provides extreme verticality and cinematic tension. IBM Plex Sans establishes neutral, austere structure. IBM Plex Mono drives digital countdown clocks ("02:47:19") and sealed letter timer locks. |
| **Astraea** | `Cormorant Garamond` (weights 400–600) | `Jost` (weights 300–600) + `JetBrains Mono` | `designs/astraea/V2 astraea-nguyên mẫu tương tác.html#9352:30-32` | Cormorant conveys mystical occult luxury for 78 tarot cards. Jost introduces celestial geometric minimalism. JetBrains Mono renders astrological coordinates, house degrees, and Roman numeral card indices. |

### 3.2 Token Hierarchies & Surface Materials

```
[Token Taxonomy Hierarchy]
├── Foundation Tier (Base Canvas, Raw Hex/RGBA, Invariant Palettes)
├── Semantic Tier (Role-bound: surface, ink, rule, accent, focus)
├── Atmospheric Tier (Layered Glows, SVG Grain Noise, Blur Glass, Starfields)
└── Geometry & Timing Tier (Radii, Touch Target Minima, Easing Transitions)
```

1. **Quire: "Tactile Paper & Warm Charcoal"**
   - **Mode**: Dual-mode (Light default, Dark via `.screen[data-theme="dark"]`).
   - **Foundation/Semantic**:
     - Light: `--paper: #FBF9F5`, `--surface: #FFFEFD`, `--s2: #F5F0EA`, `--s3: #ECE6DD`, `--ink: #241E19`, `--ink2: #605851`, `--ink3: #726A64`, `--rule: #E8E3DB`.
     - Dark: `--paper: #1A1612`, `--surface: #25211C`, `--s2: #312C26`, `--s3: #3A342C`, `--ink: #ECE9E4`, `--ink2: #ADA8A1`, `--rule: #37322C`.
     - Accent: Terracotta `--accent: #E76136` (light) / `#F0834E` (dark), `--gold: #DBA84A`, `--danger: #C13832`.
   - **Geometry**: `--r-photo: 10px`, `--r-plate: 14px`, `--r-btn: 13px`, `--r-card: 18px`, `--r-sheet: 22px`.
   - **Atmosphere**: Natural paper substrate (`radial-gradient`), crisp hairline rules, zero artificial blur or noise.

2. **Dream Journal: "Obsidian & 5-Layer Veil Glass"**
   - **Mode**: Strictly Nocturnal (Dark-only).
   - **Foundation/Semantic**:
     - `--void: #05050A`, `--void-2: #08070E`, `--obsidian: #0B0A12`.
     - Text Tiers: `--ink: #ECE7DD` (warm ivory), `--muted: rgba(236,231,221,.74)`, `--faint: rgba(236,231,221,.52)`, `--hairline: rgba(236,231,221,.11)`.
     - Illumination: Antique Gold `--gold: #C9A961`, Lunar Silver `--silver: #AEB6C4`, Deep Crimson `--crimson: #941D2E`.
   - **Glass & Atmosphere**:
     - `--glass: rgba(255,255,255,.035)`, `--glass-2: rgba(255,255,255,.062)`, `--glass-edge: rgba(203,178,124,.14)`, `--blur: 22px`.
     - Atmospheric Stack: 3 radial glow light sources (`.glow.a` silver 30%, `.glow.b` gold 20%, `.glow.c` crimson 14%) + SVG `feTurbulence` fractalNoise film grain (opacity 5%, overlay) + 120% vignette.

3. **After Midnight: "Nocturnal Void & Starfield Vignette"**
   - **Mode**: Strictly Nocturnal (00:00–05:00 active, daytime locked).
   - **Foundation/Semantic**:
     - Base Canvas: `#050505`, `--obsidian: #080808`, `--charcoal: #111111`, `--soft: #171717`.
     - Text & Accents: `--ink: #E8E6E1`, `--silver: #C8C8C8`, `--silver-dim: #8A8A8A`, `--dust: #7A756D`, `--gold: #C9A45C`, `--wine: #6E2028`, `--wine-deep: #2A1014`.
     - Lines: `--line: rgba(200,200,200,0.10)`, `--line-strong: rgba(200,200,200,0.22)`.
   - **Atmosphere**: Procedural 7-star radial grid with 12s alternate twinkle animation + 4-octave fractalNoise SVG grain (4.5% overlay) + wine-tinted bottom radial ambient flare (`rgba(110,32,40,0.16)`).

4. **Astraea: "Midnight Violet Velvet & Antique Gold"**
   - **Mode**: Strictly Nocturnal (Dark-only).
   - **Foundation/Semantic**:
     - `--bg: #0B0A12`, Canvas `#07060C`, `--surface: #171426`, `--surface-2: #211C33`.
     - Text & Inks: Ivory `--ivory: #F3EDE0`, `--muted: #9C94AC`, `--faint: #6C667F`, `--ink-on-gold: #171326`.
     - Accents: Antique Gold `--gold: #C9A86A`, Highlight `--gold-2: #E0C489`, `--gold-soft: rgba(201,168,106,0.14)`.
   - **Atmosphere**: Dual radial gradients (top gold 7%, bottom violet 10%) + 16px blurred tabbar (`background: rgba(23,20,38,.94); backdrop-filter: blur(16px)`).

### 3.3 Contrast Guardrails & Accessibility Findings
- **Explicit Contrast Engineering**:
  - `designs/dream-journal/index.html#9FC4:26-27` documents deliberate contrast ratios: `--muted: rgba(236,231,221,.74)` yields ~8:1 contrast on `--void (#05050A)`, and `--faint: rgba(236,231,221,.52)` yields ~4.5:1 (clearing WCAG AA).
  - Astraea implements explicit reverse contrast: `--ink-on-gold: #171326` against `--gold: #C9A86A`, ensuring accessible readability on primary CTA buttons.
  - Quire incorporates dedicated focus states: `--focus: 0 0 0 3px rgba(231,97,54,.34)` (light) / `rgba(240,131,78,.4)` (dark) and full reduced-motion overrides (`@media (prefers-reduced-motion: reduce)`).
- **Audit Deficit (C-91 / C-90 Alignment)**:
  - Low-contrast nocturnal metadata (such as `--dust: #7A756D` in After Midnight and `--faint: #6C667F` in Astraea) hover near the 4.5:1 threshold under subdued ambient conditions.
  - Per `c-91.md:20`, all contrast ratios in docs remain labeled `Chưa kiểm độc lập` until instrumented with automated colorimeter tools prior to production release.

---

## 4. Structural Cross-App Boundaries & Architectural Invariants

### 4.1 Invariant 1: Local-First / Zero Backend State
- **Ground Truth**: Across all 4 prototypes, there are zero server-side APIs, HTTP fetch calls, GraphQL queries, WebSocket endpoints, or cloud authentication states.
- **Architectural Guard**: Documentation must strictly avoid inventing fake API contracts or database tables. All state must be documented as client-resident UI models.

### 4.2 Invariant 2: Calm Computing & Anti-Retention
- **Ground Truth**: None of the applications contain push notification triggers, retention streaks, badge counts, algorithmic social feeds, follower tallies, or vanity metrics.
- **Destruction Mechanics**:
  - **Quire**: Automatic 30-day purge of activity moments; private photo sharing circles.
  - **Dream Journal**: Private encrypted dream vault; AI serves strictly as a non-judgmental reflective mirror.
  - **After Midnight**: Strict 00:00–05:00 temporal gateway; daytime lockout; "The Void" zero-save submission; irrevocable sealed letters.
  - **Astraea**: Non-predictive ritual divination (chiêm nghiệm, không mê tín); 2-tap complete purge of reading history.

### 4.3 Invariant 3: Autonomy & Anti-Merge Guard (C-90)
- **Constraint**: The 4 applications are deliberately distinct aesthetic and domain universes.
- **Guardrail**: Never homogenize typography into a single font stack or unify CSS variables into a shared `@theme` file. Each app owns its isolated token hierarchy and component lifecycle.

### 4.4 Invariant 4: Viewport & Device Adaptation Contract
- **Authoring Baseline**: Physical mobile viewport `min(390px, 100vw)` by `min(844px, 100vh)` with `border-radius: 44px`.
- **Harness Separation**: Responsive viewports (tablet `834x1112`, desktop centered frames) are external preview harnesses, preserving the mobile information hierarchy unmodified within.

---

## 5. Proposed Document Set & System Taxonomy

We propose a structured, hierarchical doc taxonomy that fulfills `kn-init` requirements while respecting subfolder organization:

```
.knowns/docs/
├── README.md                      # [Core] Root navigation, portfolio thesis, agent onboarding
├── ARCHITECTURE.md                # [Core] System architecture, invariants, handoff boundaries
├── CONVENTIONS.md                 # [Core] S-01 Anti-Minting, Knowns standards, UTF-8 safety
├── architecture/                  # [Architecture Subdomain]
│   ├── design-system-tokens.md    # Deep token analysis, typography pairs, materials, WCAG
│   └── cross-app-invariants.md    # Domain separation matrix, calm mechanics, lifecycle
└── constellation/                 # [Submodule Extraction Docs - Existing 12 files]
    ├── s-01-quy-c-vit-docs-constellation.md
    ├── s-02-mu-trch-xut-prototype.md
    ├── quire-01-flow.md / quire-02-data.md
    ├── dream-journal-01-flow.md / dream-journal-02-data.md
    ├── after-midnight-01-flow.md / after-midnight-02-data.md
    ├── astraea-01-flow.md / astraea-02-data.md
    ├── c-90-cross-matrix.md
    └── c-91-backlog.md
```

### 5.1 Document Specifications Table

| Path | Title | Description | Folder | Tags | Key Sections |
|---|---|---|---|---|---|
| `README` | `README — Constellation Portfolio Architecture & Core Navigation` | Tổng quan kiến trúc Constellation, định vị 4 mobile prototypes, danh mục tài liệu Knowns và điểm vào cho agent workflows. | `(root)` | `constellation`, `overview`, `navigation`, `core` | §1 Tổng quan Constellation<br>§2 4 Sản phẩm độc lập (Quire, Dream, After-Midnight, Astraea)<br>§3 Bản đồ Taxonomy tài liệu<br>§4 Workflow khởi động agent (kn-init)<br>§5 Ranh giới bất biến (Anti-Mint, Anti-Merge, Deferrals) |
| `ARCHITECTURE` | `ARCHITECTURE — Kiến trúc tổng thể hệ thống Constellation` | Kiến trúc hệ thống Constellation: mô hình Local-First, ranh giới 4 sản phẩm, các bất biến Calm UX, viewport contract và ranh giới chuyển giao prototype-to-implementation. | `(root)` | `constellation`, `architecture`, `system-design`, `core` | §1 Macro System Architecture<br>§2 Các bất biến kiến trúc (Invariants)<br>§3 Ma trận phân tách 4 Domain<br>§4 Mô hình Local-First & Vòng đời dữ liệu<br>§5 Viewport & Device Adaptation Contract<br>§6 Handoff Boundary & Risk Ledger |
| `CONVENTIONS` | `CONVENTIONS — Quy ước kỹ thuật, tài liệu & tiêu chuẩn Constellation` | Quy ước toàn dự án: Observe-only Anti-Minting contract, cấu trúc thư mục, chuẩn hóa metadata Knowns, UTF-8 safety trên Windows, và quy trình kiểm định. | `(root)` | `constellation`, `conventions`, `standards`, `core` | §1 S-01 Observe-Only & Anti-Minting Rule<br>§2 Cấu trúc thư mục & Quy tắc Taxonomy<br>§3 Tiêu chuẩn Metadata Frontmatter<br>§4 Windows UTF-8 Safety (Memory w6kiug)<br>§5 Tính bất biến của submodule (designs/* read-only)<br>§6 Tiêu chuẩn kiểm định (knowns validate) |
| `architecture/design-system-tokens` | `Design System & Token Architecture — Nền tảng thiết kế & Hệ thống Token` | Phân tích sâu hệ thống design tokens của 4 prototypes: 4 cặp typography đối lập, phân cấp token, chất liệu bề mặt (paper/obsidian/violet/void), và hàng rào tương phản WCAG. | `architecture` | `constellation`, `architecture`, `design-system`, `tokens`, `typography` | §1 Triết lý thẩm mỹ & Độc lập thị giác<br>§2 Phân tích 4 cặp Typography đối lập<br>§3 Phân cấp Token (Foundation, Semantic, Atmospheric, Geometry)<br>§4 Bề mặt & Chất liệu (Paper, Obsidian/Veil, Starfield, Violet)<br>§5 Hàng rào tương phản, Focus ring & Cảnh báo WCAG |
| `architecture/cross-app-invariants` | `Cross-App Boundaries & Architectural Invariants — Ranh giới chéo & Bất biến hệ thống` | Ma trận ranh giới kiến trúc 4 ứng dụng, các bất biến Calm Computing, cơ chế hủy/xóa dữ liệu, và nguyên tắc bảo toàn tính độc lập không hợp nhất. | `architecture` | `constellation`, `architecture`, `invariants`, `boundaries`, `anti-merge` | §1 Bất biến kiến trúc toàn hệ thống<br>§2 Ma trận ranh giới tương tác & Dữ liệu chéo<br>§3 Triết lý Calm Computing & Anti-Retention<br>§4 Cơ chế Hủy & Xóa dữ liệu (Ephemeral / Void / Wipe)<br>§5 Bảo toàn tính độc lập không hợp nhất (Anti-Merge) |

---

## 6. Mechanism-Level Trade-Offs & Risk Ledger

1. **Trade-off 1: Root Docs vs S-01 Subfolder Rule**
   - *Conflict*: `s-01:17` states "Mọi doc nằm trong `.knowns/docs`, folder `constellation`". However, `kn-init` looks strictly at `README`, `ARCHITECTURE`, and `CONVENTIONS` at `.knowns/docs/` root.
   - *Resolution (Option C)*: S-01 was written during the prototype extraction phase for app-specific extraction docs (`quire-*`, `dream-*`, etc.). Root docs (`README`, `ARCHITECTURE`, `CONVENTIONS`) serve as the top-level orchestration layer for Knowns tooling, pointing directly to `constellation/`, `architecture/`, `patterns/`, and `guides/`.
2. **Trade-off 2: Visual Token Autonomy vs Shared Engine Redundancy**
   - *Conflict*: Engineering teams may desire a shared CSS reset or unified theme utility.
   - *Risk*: Homogenization of typography, loss of tactile paper vs obsidian/veil glass distinctions, accidental leakage of daytime styles into nocturnal-only apps.
   - *Resolution*: Maintain strict namespace isolation for tokens. Shared infrastructure is restricted to tooling, validation scripts, and container harnesses.
3. **Trade-off 3: Prototype Aesthetic Contrast vs WCAG AA Compliance**
   - *Conflict*: Subtle nocturnal text tokens (`--dust: #7A756D` in After Midnight, `--faint: #6C667F` in Astraea) create intense atmosphere but sit close to the 4.5:1 threshold.
   - *Risk*: Failure of accessibility audits upon production release.
   - *Resolution*: Explicitly flag all contrast ratios as `Chưa kiểm độc lập` under C-91, and document formal colorimeter testing as an engineering prerequisite prior to production release.

---
*Report anchored to codebase files and verified against Knowns schema.*
