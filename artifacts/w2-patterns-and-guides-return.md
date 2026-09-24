# SLP V5.1 Return Packet: Interaction Patterns, Calm-UX Mechanics & Operator Guides
**Work ID:** `w2`  
**State:** `RETURNED`  
**Author:** `PeerPatternsAndGuides`  
**Date:** 2026-09-24  
**Target:** UX Domain Patterns (`patterns/`), Developer & Operator Guides (`guides/`), Anti-Minting Bridge & Invariants Preservation  

---

## 1. Executive Summary & Problem Framing

A comprehensive audit of the Constellation codebase (`designs/quire`, `designs/dream-journal`, `designs/after-midnight`, `designs/astraea`) and the existing documentation (`.knowns/docs/constellation/`) reveals a critical architectural gap:
1. **Extraction Without Abstraction**: The existing 8 application docs (`*-01-flow.md`, `*-02-data.md`) accurately catalog screens, local flows, and data fixtures. However, the cross-cutting **interaction paradigms** (e.g. Diurnal Time Gating, Ephemeral Non-Persistence, Deliberate Ritual Friction, Contemplative Stasis, WebAudio In-Browser Synthesis) remain fragmented across raw HTML script blocks and isolated notes.
2. **The Danger of Naive Handoff**: Without explicit behavioral pattern documentation, downstream engineering teams inevitably fall into one of two failure modes:
   - **Failure Mode A (Feature Distortion / Dark Patterns)**: Converting calm, private interactions into standard high-retention social networks (adding follower graphs, push reminders, streaks, permanent retention of ephemeral data, and removing ritual friction).
   - **Failure Mode B (API / Schema Minting Violations)**: Hallucinating complex backend schemas, REST/GraphQL endpoints, and ORM models for ephemeral concepts that were intentionally engineered as client-only transient mechanics (violating `S-01` and `C-91`).
3. **The Option C Solution (Behavioral State Machine & Handoff Boundary)**: Bridge the design-to-engineering gap by formalizing **Domain Pattern Specifications** under `patterns/` and **Operator & Boundary Guides** under `guides/`. These documents specify state transitions, behavioral invariants, timing constraints, and negative requirements (what *must never* be built) using formal prose, state charts, and mathematical invariants—without minting a single phantom API or database field.

---

## 2. Missing Pattern Docs Analysis (`patterns/`)

We have designed 4 foundational pattern documents that capture the calm, anti-retention, and resilient interaction dynamics across all 4 prototypes.

### 2.1 Pattern P-01: Ephemeral & Privacy Lifecycles (`patterns/ephemeral-privacy-lifecycles.md`)
- **Domain Thesis**: Constellation applications treat data retention as a liability rather than an asset. User data exists on an intentional spectrum from instantaneous memory evaporation to bounded, self-purging local archives.
- **Observed Mechanisms & Ground Truth Anchors**:
  - **The Void Evaporation (`after-midnight`)**: User types up to 400 characters of unburdening thoughts (`designs/after-midnight/v1 after midnight - interactive prototype.html#19F5:676-679`). Upon triggering `LET IT GO`, the text does not transmit over a network or save to storage. Instead, `letGo()` decomposes the text into individual `span` elements, applies a CSS particle drift/blur dissolve over 1600ms, and at 2100ms executes an in-memory wipe: `state.voidDraft = ''; state.voidGone = true;` (`#19F5:764-784`). If `prefers-reduced-motion` is active, the DOM is zeroed immediately without animation (`#19F5:767`).
  - **Sealed Letters Immutability (`after-midnight`)**: Letters written in the Post Office are assigned a time-delay horizon (Tomorrow, 7 days, 30 days, 1 year). Upon departure, the letter transitions to `SEALED` and becomes strictly immutable (`#19F5:27, 43, 61`).
  - **Bounded Circles & Unsend Grace Buffer (`quire`)**: Moments are shared strictly with small, bounded circles (e.g. 11 persons; `#600B:344, 436`). An unsend action is provided with instant feedback: `"Send cancelled. Nothing left the app."` (`#600B:344`).
  - **30-Day Auto-Purge Lifecycle (`quire`)**: The activity log enforces an automatic time-to-live: `"không có gì cũ hơn 30 ngày"`; items beyond 30 days self-purge (`designs/quire/design-notes.md#BA1E:39-42`).
  - **5-Layer Veil Sanctum (`dream-journal`)**: Dreams are shielded behind 5 contemplative layers (Giấc mơ → Ảo ảnh → Ký ức → Cảm xúc → Bản ngã), ensuring that deep introspective content requires deliberate multi-stage peeling (`designs/dream-journal/index.html#9FC4:553-562`).
  - **2-Tap Complete Local Wipe (`astraea`)**: Personal tarot readings reside strictly in local client state and can be completely purged with zero cloud residuals in 2 taps (`designs/astraea/readme.md#8EDE:42`).
- **Core Invariant**:
  $$\forall d \in \text{TheVoid}, \quad \text{Storage}(d) = \emptyset \quad \wedge \quad \text{Telemetry}(d) = \emptyset$$
  $$\forall m \in \text{ActivityFeed}, \quad \text{TTL}(m) \le 30 \text{ days} \implies \text{AutoPurge}(m)$$

### 2.2 Pattern P-02: Temporal & Ritual State Machines (`patterns/temporal-ritual-state-machines.md`)
- **Domain Thesis**: Replacing continuous, impulsive user engagement with synchronous diurnal gates and sacred, non-commutative ritual state machines.
- **Observed Mechanisms & Ground Truth Anchors**:
  - **Diurnal Time-Gating (`after-midnight`)**: The nocturnal city exists strictly between 00:00 and 05:00 (`designs/after-midnight/readme.md#B144:5`). The system cycles through 4 discrete states:
    1. `Day` (05:00–Dusk): Locked state, countdown ticker active (`#19F5:722, 738`).
    2. `Dusk` (Dusk–00:00): Soft-lock anticipation state, allows manual early preview toggle.
    3. `Midnight` (00:00–05:00): Active state. 8 nocturnal spaces open; the 5-tab navigation bar (`tabbar`) is revealed *strictly* during this state (`#19F5:449-451: tabbar.hidden = !inNight`).
    4. `Dawn` (05:00 transition): Closure state. Gates close; routes redirect to the Archive (`#19F5:693, 724`).
  - **6-Step Divination Ritual (`astraea`)**: The tarot reading workflow is a strictly linear, non-commutative finite state machine:
    $$\text{Inquiry} \xrightarrow{1} \text{Spread Selection} \xrightarrow{2} \text{Card Fanning \& Pick} \xrightarrow{3} \text{Sequential 3D Reveal} \xrightarrow{4} \text{Interpretation} \xrightarrow{5} \text{Journal Archive}$$
    Card reveals require discrete user triggers per card (`flipBtn` $\to$ `nextReveal` $\to$ `toResult`; `#9352:457-461, 728-732`). Aborting the ritual resets uncommitted draws to pristine state (`#9352:52`).
  - **Dream Reveal Transformation (`dream-journal`)**: Raw voice/drawing/text fragments undergo a mandatory "Reveal" transformation step (`Hé lộ giấc mơ`), converting raw data into an artistic celestial artifact before entering the sky map (`designs/dream-journal/README.md#B48F:58-64`).

### 2.3 Pattern P-03: Calm Computing & Anti-Social Mechanics (`patterns/calm-anti-social-mechanics.md`)
- **Domain Thesis**: Systematic elimination of dark patterns, psychological coercion, algorithmic dopamine loops, and performative social metrics.
- **Observed Mechanisms & Ground Truth Anchors**:
  - **Negative Invariants (Forbidden Features List)**: Across all 4 applications, the following are strictly prohibited:
    - Zero follower counts, zero public profiles, zero popularity graphs (`designs/quire/design-notes.md#BA1E:39`).
    - Zero streaks, zero gamification badges, zero leveling mechanics (`#BA1E:40`).
    - Zero re-engagement push notifications, zero guilt badges (`#BA1E:41`).
  - **Quiet by Default**:
    - Push notifications are pre-set to off (`designs/quire/prototype.html#600B:460`).
    - Read receipts are explicitly disabled by default (`#600B:371: readReceiptsSub: 'Off by default'`, `#600B:460: readReceipts: false`).
    - Dedicated Quiet Hours are enforced (22:00–07:00; `quire-01-flow.md:31`).
  - **Contemplative Stasis (Non-Action Spaces)**:
    - *The Rooftop / Sân thượng (`after-midnight`)*: Completely devoid of CTA buttons, input fields, or scroll feeds (`#19F5:510; after-midnight-01-flow.md:30, 63`). It is an intentional digital sanctuary for passive contemplation.
  - **Reflective Non-Deterministic Voice**:
    - AI dialogue in Dream Journal and tarot interpretations in Astraea strictly mirror the user's emotions rather than predicting fate, diagnosing psychological disorders, or manufacturing existential anxiety (`designs/dream-journal/index.html#9FC4:583`, `designs/astraea/readme.md#8EDE:38: "giọng thơ nhưng có đất, không tiên tri, không gieo sợ"`).
  - **Liberating Wait Pacing**:
    - Asynchronous processing delays (e.g. 20-second dream reflection) explicitly reassure the user: `"Thường mất khoảng 20 giây. Bạn có thể rời màn hình này"` (`dream-journal-01-flow.md:63`). The software explicitly invites the user to disengage and put the device away.

### 2.4 Pattern P-04: Offline Resilience & Ambient Fallbacks (`patterns/offline-ambient-fallbacks.md`)
- **Domain Thesis**: Complete self-containment, local-first asset generation, and graceful aesthetic degradation under severe network disconnectivity.
- **Observed Mechanisms & Ground Truth Anchors**:
  - **Zero-Remote Asset Architecture**:
    - Astraea renders all 78 tarot cards as inline scalable vector graphics (`SVG`), eliminating all remote image latency and CDN failure points (`designs/astraea/readme.md#8EDE:35`).
    - Dream Journal constructs its celestial sky maps, 5-layer veils, and materials entirely via inline CSS/SVG filters (`feTurbulence`), with zero bitmap dependencies (`designs/dream-journal/README.md#B48F:76, 98`).
  - **Synthesized WebAudio Soundscapes (`after-midnight`)**:
    - Background ambient drone and analog radio noise are synthesized client-side via the browser's `AudioContext`, pink noise buffers, and dual sine oscillators (`#19F5:410-439`). Zero MP3/WAV files are fetched across the network.
  - **Graceful Image & Font Degradation**:
    - External placeholder images from `picsum.photos` in Quire utilize `<img onerror="this.remove()">` (`#600B:316`). If the network fails, the image node seamlessly detaches, leaving a perfectly styled paper substrate card with a clean typography label, completely avoiding broken-image icons or reflow jank.
    - All typography definitions implement deep system fallback stacks:
      - Display Serif: `Instrument Serif`, `Cormorant Garamond`, `Newsreader` $\to$ `Iowan Old Style`, `Georgia`, `Times New Roman`, `serif`.
      - Sans / UI: `IBM Plex Sans`, `Be Vietnam Pro`, `Jost` $\to$ `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, `system-ui`, `sans-serif`.
      - Monospace: `IBM Plex Mono`, `JetBrains Mono` $\to$ `ui-monospace`, `SFMono-Regular`, `Menlo`, `monospace`.
  - **Reduced Motion Degradation**:
    - Every prototype observes `prefers-reduced-motion`. All 3D transforms, particle drifts, and coordinate shifts automatically collapse into gentle opacity crossfades (`#19F5:393, 767; designs/dream-journal/README.md#B48F:77`).

---

## 3. Missing Guides Analysis (`guides/`)

To enable human developers, QA testers, and autonomous agents to interact with, evaluate, and implement these prototypes without violating project invariants, two comprehensive operator guides are required.

### 3.1 Guide G-01: Prototype Navigation & Inspection Guide (`guides/prototype-navigation-inspection.md`)
- **Target Audience**: Autonomous agents (SLP subagents), frontend engineers, QA automation specialists, design auditors.
- **Key Operational Areas**:
  1. **Execution Environments**: Native browser execution without bundlers, node servers, or npm scripts. Exact shell launch commands across OS platforms (`powershell: start "" "file.html"`, `open`, `xdg-open`).
  2. **Dual-Artifact Modality**:
     - *Interactive Prototype (`prototype.html`, `interactive prototype.html`, `index.html`)*: Bounded mobile frame (`390x844`), fully interactive state machines, tabbars, dialog overlays.
     - *Infinite Design Canvas (`design-board.html`, `infinite canvas.html`, `canvas.html`, `Bản đồ toàn cảnh.html`)*: Spatial layout of all 15–22 screens, vector connection lines, annotations. Teaches navigation: Background Drag to Pan, `Ctrl/Cmd + Wheel` to Zoom, `Ctrl/Cmd + Z` to Undo spatial rearrangement.
  3. **Control Mechanics & Harnesses**:
     - Manipulating the After-Midnight temporal slider (`.timepanel button[data-val="day|dusk|midnight|dawn"]`).
     - Toggling Quire's bilingual engine (`t()` key lookup across 126 EN/VI pairs) and 4-tier settings navigation.
     - Triggering Astraea's 6-step card draw ceremony and 3D card flip.
     - Peeling Dream Journal's 5 veil layers and testing keyboard navigation (`Esc` to return, `←/→` arrow keys to cycle screens).
  4. **DevTools Inspection Protocols**:
     - Locating token declarations in `:root`.
     - Inspecting `window.AudioContext` state (`audio.ctx.state === 'suspended'|'running'`).
     - Emulating `@media (prefers-reduced-motion: reduce)` in the Rendering drawer.
     - Differentiating fully wired interactive screens from display-only mockup states (intercepting `.notWired` and toast notifications).

### 3.2 Guide G-02: Prototype-to-Implementation Boundary Guide (`guides/prototype-to-implementation-boundary.md`)
- **Target Audience**: Technical architects, backend engineers, security leads, database modelers.
- **Governance Mandate**: Enforces the strict demarcation between design prototype observations and future engineering requirements, upholding `S-01`, `C-90`, and `C-91`.
- **Key Boundary Demarcations**:
  1. **UI Mock Models $\neq$ Database Schemas (Data Boundary)**:
     - Prototype JS state objects (e.g. `state.thoughts`, `state.drawn`, `FRAG`) are client-side rendering fixtures, *not* relational schemas or document structures.
     - Engineers MUST NOT mint SQL tables or Prisma schemas directly from UI object shapes.
  2. **Client Simulations $\neq$ Production Security (Security Boundary)**:
     - The client-side `.timepanel` in After Midnight is a development testing harness. In production, nocturnal gating must be synchronized against trusted, tamper-proof time authorities.
     - The client-side DOM wipe in The Void must be backed in production by strict memory-zeroing protocols that guarantee no swap-file leakage or crash-dump logging.
  3. **Local State $\neq$ Distributed Protocol (Sync Boundary)**:
     - Per `C-91 §1`, all cloud backend, user authentication, and multi-device synchronization features are deferred. No team may invent sync protocols or REST endpoints during the prototype extraction phase.
  4. **Prototyping Fixtures $\neq$ Production Assets (Asset Boundary)**:
     - Remote placeholder URLs (`picsum.photos`) and CDN fonts (`fonts.googleapis.com`) must be replaced in production releases with self-hosted, offline-bundled assets.
  5. **Formal Handoff Protocol**:
     - Step 1: Extract visual and behavioral invariants from the prototype.
     - Step 2: Cross-check against the `c-91-backlog.md` deferral list.
     - Step 3: Explicitly tag any newly proposed interface or contract as `[PROPOSED NEW CONTRACT]`.
     - Step 4: Submit to Lead review before implementation.

---

## 4. Bridging the Gap: Anti-Minting & Invariants Preservation

### 4.1 The Architectural Tension
A recurring challenge in software engineering is the transition from high-fidelity interactive design prototypes to production software:
- If engineers are given bare prototypes without pattern documentation, they naturally impose familiar paradigms: CRUD databases, RESTful endpoints (`POST /api/v1/void`, `GET /api/v1/timegate`), analytics trackers, push notifications, and social feeds.
- If engineers are strictly forbidden from writing code without documentation, they demand formal API contracts and schemas prematurely.

### 4.2 The Option C Solution: Behavioral State Contracts
The Pattern Docs (`patterns/`) and Guides (`guides/`) bridge this chasm by formalizing **Behavioral State Contracts** rather than **Implementation Contracts**:

```
[Design Prototype HTML/JS]
          │
          ▼
[Behavioral State Contracts (patterns/ & guides/)]
  • State Transition Matrices ($S_0 \xrightarrow{E} S_1$)
  • Temporal & Sensory Invariants ($I_{\text{Void}}, I_{\text{Temporal}}$)
  • Anti-Features & Negative Requirements (What MUST NOT exist)
          │
          ▼
[Future Engineering Implementation (Post C-91)]
  • Safe, uncompromised backend architectures that respect calm invariants
  • Zero API hallucination during the docs phase
```

By documenting the *exact behavioral constraints* (e.g. "Void data must be zeroed from RAM within 2100ms; no disk write may occur; no server payload may be transmitted"), we establish immutable requirements for future backend engineers without inventing a single phantom endpoint today.

---

## 5. Structured Doc Specifications Table

The following 6 documents are specified for inclusion in `.knowns/docs/`:

| Path | Title | Description | Folder | Tags | Key Sections |
|---|---|---|---|---|---|
| `patterns/ephemeral-privacy-lifecycles` | `Ephemeral & Privacy Lifecycles — Vòng đời dữ liệu tạm thời & Cơ chế riêng tư cốt lõi` | Phân tích cơ chế và bất biến của dữ liệu tạm thời, The Void không lưu, thư niêm phong khóa thời gian, chu kỳ 30 ngày tự hủy và vòng tròn riêng tư hữu hạn trong 4 prototypes. | `patterns` | `constellation`, `patterns`, `privacy`, `ephemeral`, `lifecycle` | §1 Triết lý Calm Privacy & Dữ liệu tối giản<br>§2 Cơ chế The Void: DOM Dissolve & Cam kết không lưu<br>§3 Cơ chế Thư niêm phong: Khóa thời gian & Tính bất biến<br>§4 Vòng tròn hữu hạn & Hoàn tác gửi Quire<br>§5 Chu kỳ tự hủy nhật ký 30 ngày<br>§6 5 tầng màn che riêng tư nội tâm Dream Journal<br>§7 Xóa dữ liệu 2 chạm Astraea<br>§8 Ma trận vòng đời & Failure-modes |
| `patterns/temporal-ritual-state-machines` | `Temporal & Ritual State Machines — Máy trạng thái thời gian & Nghi thức tương tác` | Phân tích máy trạng thái 4 nấc thời gian After Midnight, luồng nghi thức 6 bước tuần tự Astraea, và chuỗi chuyển hóa từ ghi chép thô đến hé lộ tác phẩm Dream Journal. | `patterns` | `constellation`, `patterns`, `temporal`, `ritual`, `state-machine` | §1 Nhịp điệu thời gian & Trải nghiệm chậm rãi<br>§2 Cổng thời gian Diurnal 4 nấc After Midnight<br>§3 Trạng thái điều hướng theo thời gian (Ẩn/hiện tabbar)<br>§4 Nghi thức rút bài 6 bước tuần tự Astraea<br>§5 Cơ chế lật thẻ 3D & Lật ngược/xuôi<br>§6 Chuỗi chuyển hóa Giấc mơ: Ghi chép → Hé lộ → Chiêm nghiệm<br>§7 Cơ chế bộ đếm thời gian (Countdown, Radio, Wave)<br>§8 Ma trận chuyển trạng thái & Failure-modes |
| `patterns/calm-anti-social-mechanics` | `Calm Computing & Anti-Social Mechanics — Cơ chế tương tác tĩnh & Chống thao túng tâm lý` | Phân tích các nguyên tắc Calm Computing, danh mục cấm tuyệt đối (Anti-Features), không gian tĩnh lặng phi hành động, mặc định im lặng và giọng đối thoại phản chiếu không phán xét. | `patterns` | `constellation`, `patterns`, `calm-ux`, `anti-social`, `ethics` | §1 Triết lý Calm Computing & Anti-Retention<br>§2 Danh mục cấm tuyệt đối (Zero metrics, no streaks, no badges)<br>§3 Không gian phi hành động (Contemplative Stasis: Sân thượng)<br>§4 Mặc định im lặng (Quiet by Default & Read receipts off)<br>§5 Giọng đối thoại phản chiếu (Reflective Prompting Invariant)<br>§6 Ma sát tích cực & Giải phóng người dùng<br>§7 Ranh giới thoái hóa & Failure-modes |
| `patterns/offline-ambient-fallbacks` | `Offline Resilience & Ambient Fallbacks — Dự phòng ngoại tuyến & Suy giảm thẩm mỹ duyên dáng` | Phân tích kiến trúc tự chứa không CDN, đồ họa vector SVG nội tuyến, tổng hợp âm thanh WebAudio, chuỗi phông chữ dự phòng có dấu tiếng Việt và xử lý ảnh mất mạng. | `patterns` | `constellation`, `patterns`, `offline`, `resilience`, `fallback`, `webaudio` | §1 Kiến trúc tự chứa (Self-Contained Single-File Deliverable)<br>§2 Đồ họa Vector SVG nội tuyến (78 lá bài Astraea, bản đồ sao)<br>§3 Tổng hợp âm thanh tại chỗ (Browser WebAudio Generator)<br>§4 Chuỗi phông chữ dự phòng & Bảo toàn tiếng Việt<br>§5 Dự phòng ảnh mất mạng (Graceful Placeholder Cards)<br>§6 Trạng thái suy giảm kết nối & Báo lỗi êm ái<br>§7 Hỗ trợ giảm chuyển động (prefers-reduced-motion)<br>§8 Failure-modes ngoại tuyến & Rủi ro âm thanh |
| `guides/prototype-navigation-inspection` | `Prototype Navigation & Inspection Guide — Hướng dẫn điều hướng & Thẩm định kỹ thuật prototype` | Cẩm nang vận hành chi tiết cho kỹ sư, QA và agent: cách mở, chạy, tương tác, kiểm tra infinite canvas, sử dụng công cụ DevTools và phân biệt màn nối thật vs màn tượng trưng. | `guides` | `constellation`, `guides`, `prototype`, `inspection`, `devtools`, `qa` | §1 Khởi động nguyên mẫu (Zero-install browser commands)<br>§2 Hai hình thái tài sản: Interactive Prototype vs Infinite Canvas<br>§3 Thao tác trên Infinite Design Canvas (Pan, Zoom, Undo, Wire lines)<br>§4 Thao tác trên Interactive Prototype (Tabs, Timepanel, i18n)<br>§5 Thẩm định kỹ thuật qua DevTools (Tokens, WebAudio, Motion)<br>§6 Phân biệt màn nối thật vs Màn tượng trưng (notWired toasts)<br>§7 Danh mục kiểm tra tiền bay (Pre-flight Inspection Checklist) |
| `guides/prototype-to-implementation-boundary` | `Prototype-to-Implementation Boundary Guide — Hướng dẫn phân định ranh giới giữa prototype và triển khai` | Khung quản trị kỹ thuật phân định ranh giới bất biến giữa quan sát prototype và triển khai tương lai, bảo vệ S-01 (Anti-Minting), C-90 (Anti-Merge) và C-91 (Backlog Deferrals). | `guides` | `constellation`, `guides`, `handoff`, `boundary`, `anti-minting`, `engineering` | §1 Nguyên lý ranh giới bất biến (Observe-only vs Speculative)<br>§2 Ranh giới dữ liệu: Mẫu UI KHÔNG PHẢI schema CSDL<br>§3 Ranh giới thời gian & bảo mật: Giả lập KHÔNG PHẢI bảo mật production<br>§4 Ranh giới đồng bộ: Local state KHÔNG PHẢI sync protocol<br>§5 Ranh giới tài sản: CDN & Picsum KHÔNG PHẢI production assets<br>§6 Quy trình bàn giao hợp lệ (Step-by-step Handoff Protocol)<br>§7 Sổ tay rủi ro & Ma trận hậu quả khi phá vỡ ranh giới |

---

## 6. Mechanisms & Invariants Preserved

1. **Non-Persistence Invariant ($I_{\text{Void}}$)**:
   Any user input submitted to The Void must be completely purged from client memory and never persisted to local disks, network requests, crash logs, or analytics pipelines.
2. **Time-Locked Immutability ($I_{\text{Sealed}}$)**:
   Sealed letters become read-only immediately upon departure and cannot be modified or unsealed until the target date arrives.
3. **Diurnal Gate Invariant ($I_{\text{Diurnal}}$)**:
   Nocturnal spaces and bottom tab navigation in After Midnight are strictly inaccessible outside the 00:00–05:00 window.
4. **Non-Commutative Ritual Order ($I_{\text{Ritual}}$)**:
   Divination in Astraea must follow the exact 6-step sequence without skips or out-of-order execution; uncommitted rituals reset upon abort.
5. **Calm Non-Metric Invariant ($I_{\text{Calm}}$)**:
   Zero social graphs, zero follower counts, zero streaks, zero gamification badges, zero unprompted re-engagement notifications.
6. **Contemplative Stasis Invariant ($I_{\text{Stasis}}$)**:
   The Rooftop screen in After Midnight must remain free of calls-to-action, buttons, or input prompts.
7. **Reflective Non-Judgmental Voice ($I_{\text{Voice}}$)**:
   AI reflections and tarot card interpretations must adhere to reflective, non-fatalistic, and non-prescriptive framing.
8. **Self-Contained Local Resilience ($I_{\text{Offline}}$)**:
   Core application operation, vector card rendering, and ambient audio generation must function entirely offline without remote API or CDN dependencies.

---

## 7. Mechanism-Level Trade-Offs & Failure Modes

1. **Frictional Slowness vs Modern User Impatience**:
   - *Trade-off*: Deliberate multi-step rituals (Astraea 6 steps) and simulated 20-second reflection delays (Dream Journal) intentionally slow down interaction.
   - *Risk*: Users accustomed to instant dopamine hits may abandon the application.
   - *Mitigation*: Calming system copy ("Hít một hơi, rồi lật lá bài khi bạn thấy sẵn sàng", "Bạn có thể rời màn hình này") reframes waiting as intentional personal space.
2. **Absolute Ephemerality vs Regretful Data Loss**:
   - *Trade-off*: Zero persistence in The Void and 30-day activity purge means accidental loss cannot be recovered.
   - *Risk*: Frustrated users requesting data recovery.
   - *Mitigation*: Clear character count and warning helper text before release ("Nội dung sẽ biến mất ngay khi bạn thả"), combined with immediate unsend grace buffers in Quire.
3. **Client-Side Simulation vs Production Tampering**:
   - *Trade-off*: Prototypes use simple client-side timers and a bottom `.timepanel` slider for instant testing.
   - *Risk*: Implementing client-side time checks in production allows users to bypass the 00:00–05:00 lock simply by changing their device clock.
   - *Mitigation*: The Boundary Guide explicitly flags client-side temporal sliders as test fixtures and requires trusted, network-synchronized time services for production release.
4. **Vector Self-Containment vs Memory Footprint**:
   - *Trade-off*: Inlining 78 complex SVG tarot cards and WebAudio synthesis routines ensures 100% offline resilience but increases single-file markup size (~15,000 DOM nodes).
   - *Risk*: Lower-end mobile devices may experience slight initial parsing latency.
   - *Mitigation*: SVGs use clean, un-nested geometric paths without base64 raster embeddings; WebAudio oscillators generate sound dynamically with zero memory overhead.

---
*Report anchored to codebase files and verified against S-01, C-90, C-91, and Knowns schema.*
