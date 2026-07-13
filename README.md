# Echoes of the Shattered Veil · 破碎帷幕的回响

[English](#english) · [简体中文](#简体中文)

![The Shattered Spire](assets/lore_art/shattered_spire_panorama.png)

<a id="english"></a>
## English

**Echoes of the Shattered Veil** is an open-source, bilingual, data-driven narrative roguelike built with Godot 4.3+. Enter a living tower that rebuilds itself from memory, survive strict turn-based encounters, and decide whether painful truth should be repaired, released, ruled, or carried together. English is the default language; Simplified Chinese can be selected in game.

### v0.1.2 — Act I playable vertical slice

- Procedural, multi-floor Ashen Narthex with guaranteed narrative-room injection.
- Permadeath loop returning to the Echo Sanctum, with persistent Echo Essence.
- Energy-timeline combat, equipment, procedural affixes, stacking statuses, traps, elites, and multiple AI profiles.
- Field of view and persistent explored-map memory.
- Branching Maelin dialogue, six lore threads, memory visions, a quest, and the story-driven Caedmon Boss encounter.
- Complete English and Simplified Chinese UI and narrative content.
- Keyboard, gamepad, and touch-oriented semantic input.
- Data-authored entities, items, effects, dialogue, lore, quests, Story Beats, and endings.

### Controls

| Action | Keyboard |
|---|---|
| Move | `Q W E / A D / Z S C` |
| Wait | `V` |
| Confirm / Cancel | `Space` / `X` |
| Inventory / Codex / Map | `I` / `L` / `M` |
| Message history | `H` |
| Pause | `P` |

Touch controls appear on mobile-sized displays. Gamepad cardinal input is combined into eight-way grid movement.

### Run locally

1. Install Godot 4.3 or newer.
2. Clone this repository.
3. Open `project.godot`, then run the main scene.

Verification:

```bash
godot --headless --editor --path . --quit
GODOT_BIN=godot tools/content_validation/run_all.sh
```

### Architecture and content authoring

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — service boundaries, Components, data flow, persistence, generation, and release design.
- [`NARRATIVE_BIBLE.md`](NARRATIVE_BIBLE.md) — canon, four Acts, cast, reveals, endings, and bilingual voice.
- [`DATA_TEMPLATES.md`](DATA_TEMPLATES.md) — practical `.tres` and JSON authoring templates.
- [`TODO.md`](TODO.md) — prioritized roadmap.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution and validation workflow.

Ordinary content is authored through custom Godot Resources or JSON and resolved through stable namespaced IDs. Content files cannot execute arbitrary code or dynamic `eval` expressions.

### Builds, website, and license

Semantic version tags trigger GitHub Actions exports for Windows, macOS, Linux, Web, and Android, publish SHA-256 checksums, and update the [latest GitHub Release](https://github.com/emptysuns/echoes-of-the-shattered-veil/releases/latest). Visit the [official GitHub Pages site](https://emptysuns.github.io/echoes-of-the-shattered-veil/). Android artifacts currently use a debug keystore and are intended for testing.

Code, documentation, and generated project artwork are available under the [MIT License](LICENSE).

---

<a id="简体中文"></a>
## 简体中文

**《破碎帷幕的回响》**是一款使用 Godot 4.3+ 开发的开源、中英双语、数据驱动叙事 roguelike。进入一座会依照记忆重构自身的活体尖塔，在严格回合制战斗中生存，并决定痛苦的真相应被缝合、释放、统治，还是共同承担。游戏默认使用英语，可在游戏内切换为简体中文。

### v0.1.2 — 第一幕可玩垂直切片

- 程序生成的多层“灰烬前殿”，每层保证注入叙事房间。
- 永久死亡循环：死亡后返回“回响圣所”，并保留“回响精华”。
- 能量时间轴战斗、装备、程序词缀、可叠加状态、陷阱、精英怪与多种 AI 行为。
- 视野系统与永久保留的已探索地图记忆。
- 梅琳分支对话、六条 lore 线索、记忆幻象、任务，以及故事驱动的凯德蒙 Boss 战。
- 完整的英语和简体中文 UI 与叙事内容。
- 支持键盘、手柄及面向触屏的语义输入。
- 实体、物品、效果、对话、lore、任务、Story Beat 与结局均由数据定义。

### 操作方式

| 动作 | 键盘 |
|---|---|
| 移动 | `Q W E / A D / Z S C` |
| 等待 | `V` |
| 确认 / 取消 | `Space` / `X` |
| 背包 / 图鉴 / 地图 | `I` / `L` / `M` |
| 消息历史 | `H` |
| 暂停 | `P` |

移动端尺寸下会显示触控按钮；手柄方向输入会组合为八方向网格移动。

### 本地运行

1. 安装 Godot 4.3 或更高版本。
2. 克隆本仓库。
3. 打开 `project.godot`，运行主场景。

验证命令：

```bash
godot --headless --editor --path . --quit
GODOT_BIN=godot tools/content_validation/run_all.sh
```

### 架构与内容创作

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — 服务边界、组件、数据流、持久化、生成与发布设计。
- [`NARRATIVE_BIBLE.md`](NARRATIVE_BIBLE.md) — 世界设定、四幕剧情、角色、揭示、结局与双语文风。
- [`DATA_TEMPLATES.md`](DATA_TEMPLATES.md) — `.tres` 与 JSON 内容创作模板。
- [`TODO.md`](TODO.md) — 按优先级划分的路线图。
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — 贡献与验证流程。

常规内容全部通过自定义 Godot Resource 或 JSON 创作，并使用稳定的命名空间 ID 解析。内容文件不能执行任意代码或动态 `eval` 表达式。

### 构建、网站与许可证

语义化版本标签会触发 GitHub Actions，为 Windows、macOS、Linux、Web 与 Android 导出构建，发布 SHA-256 校验文件并更新[最新 GitHub Release](https://github.com/emptysuns/echoes-of-the-shattered-veil/releases/latest)。欢迎访问[官方 GitHub Pages 网站](https://emptysuns.github.io/echoes-of-the-shattered-veil/)。Android 产物目前使用调试密钥签名，仅供测试。

代码、文档及项目生成美术均采用 [MIT License](LICENSE) 开源。
