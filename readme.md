# 🎯 DDCZ Scoreboard

> Modern, optimized and fully customizable scoreboard for **QBCore** servers.  
> Clean UI, smart refresh system, activity groups, 3D ID tags and built-in testing mode.

---

## 📌 Overview

| Property | Value |
|----------|--------|
| 👨‍💻 Author | DDCZ Dev |
| 🏷 Version | 1.0.0 |
| ⚙ Framework | QBCore |
| 📦 Dependencies | None (no ox_lib required) |
| 🖥 UI | HTML / CSS / JS (NUI) |

---

# 🚀 Installation

### 1️⃣ Copy the resource

Move:

```
ddcz-scoreboard
```

into:

```
resources/[custom]/
```

### 2️⃣ Add to `server.cfg`

```
ensure ddcz-scoreboard
```

### 3️⃣ Restart

```
restart ddcz-scoreboard
```

✅ No additional dependencies required.

---

# ⚠ Fix Warning: `locales/*.lua`

If you see:

```
Warning: could not find shared_script `locales/*.lua`
```

### 📌 Cause
Older `fxmanifest.lua` referencing locale files that no longer exist.

### ✅ Solution
- Delete the entire `ddcz-scoreboard` folder
- Upload this version
- Make sure `fxmanifest.lua` does **NOT** contain:
  ```
  locales/*.lua
  ```

Localization is now handled directly in JavaScript.

---

# 🎮 Controls

| Key | Action |
|------|--------|
| 🎯 F10 | Open / Close scoreboard |
| ⬅ ➡ | Switch pages |
| ⬆ | Toggle 3D ID tags |
| 💬 `/scoreboard` | Open scoreboard |
| 💬 `/sc` | Command alias |

Keys can be changed in:

```lua
Config.ToggleKeyId
Config.IDTagKeyId
```

FiveM control reference:  
https://docs.fivem.net/docs/game-references/controls/

---

# ⚙ Configuration (`config.lua`)

## 🌐 General

| Option | Description |
|--------|------------|
| `Config.ServerName` | Server name displayed in header |
| `Config.ServerTagline` | Subtitle under name |
| `Config.Locale` | UI language (`cs`, `en`, `de`, `pl`, `sk`) |

---

## 🎮 Controls

| Option | Default | Description |
|--------|----------|------------|
| `Config.ToggleKeyId` | 57 (F10) | Toggle scoreboard |
| `Config.IDTagKeyId` | 172 (Arrow Up) | Toggle 3D tags |
| `Config.Command` | `scoreboard` | Chat command |
| `Config.CommandAlias` | `sc` | Command alias |

---

## 🔄 Performance

| Option | Default | Description |
|--------|----------|------------|
| `Config.RefreshInterval` | 5000 ms | Data refresh rate |
| `Config.PlayersPerPage` | 25 | Players per page |
| `Config.IDTagDistance` | 30m | 3D tag max distance |

---

## 📊 Columns

| Option | Description |
|--------|------------|
| `Config.ShowPing` | Show ping column |
| `Config.ShowJob` | Show job column |
| `Config.ShowActivity` | Show activity bar |

---

# 👥 Activity Groups

Displayed above the player list.  
Each group can include multiple `job.name` values.

```lua
Config.ActivityGroups = {
    {
        label = 'POLICE',
        icon = 'fa-shield-halved',
        color = '#00b8ff',
        jobs = { 'police', 'sheriff', 'swat' },
        includeOffDuty = false,
    },
    {
        label = 'MEDIC',
        icon = 'fa-heart-pulse',
        color = '#ff3b3b',
        jobs = { 'ambulance', 'doctor' },
        includeOffDuty = false,
    },
    {
        label = 'MECHANIC',
        icon = 'fa-wrench',
        color = '#ffb020',
        jobs = { 'mechanic', 'lsc', 'bennys' },
        includeOffDuty = true,
    },
}
```

### 📝 Notes
- `jobs` must match `job.name` in QBCore database
- Icons: https://fontawesome.com/icons (remove `fa-` prefix)

---
---

# 🆔 3D ID Tags

Press ⬆ to toggle locally.

### Features
- Displays: `[ID] PlayerName`
- Distance scaling
- Configurable max distance
- Visible above your own head
- Fully local (does not affect others)

---

# 📄 Pagination

When players exceed `Config.PlayersPerPage`:

| Method | Action |
|--------|--------|
| ⬅ ➡ Keys | Change page |
| UI Arrows | Click navigation |

### Smart Refresh
- Full render only when needed
- Ping/job updates inline
- No flickering
- Page remains selected after refresh

---

# 🧠 Job Handling (Technical)

Uses:

```lua
QBCore.Functions.GetQBPlayers()
```

Returns internal `QBCore.Players` table with valid server sources.

❌ `GetPlayers()` + `GetPlayer(id)` is incorrect  
(because `GetPlayers()` returns network indexes)

### Jobs update on:
1. Refresh interval
2. `QBCore:Server:OnJobUpdate`
3. Player join/leave

Instant job updates without waiting for refresh.

---

# 🛡 Admin / Mod Badges

| Permission | Badge | Color |
|------------|--------|-------|
| `admin` | ADMIN | Purple |
| `mod` | MOD | Blue |

Set via:

```
/setpermission [id] admin
/setpermission [id] mod
```

---

# 🌍 Localization

Supported languages:

- 🇨🇿 Czech
- 🇬🇧 English
- 🇩🇪 German
- 🇵🇱 Polish
- 🇸🇰 Slovak

Set:

```lua
Config.Locale = 'en'
```

Localization is handled in:

```
html/js/app.js
```

To add a new language, modify the `L10N` section.

---

# 🌐 Browser Preview

Open directly in browser:

```
html/index.html
```

Automatically loads 100 fake players for preview.

---

# 📂 File Structure

```
ddcz-scoreboard/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
├── readme.txt
└── html/
    ├── index.html
    ├── css/style.css
    └── js/app.js
```
---

# 💎 Features Summary

- ⚡ Instant job updates  
- 🧠 Smart rendering system  
- 🧪 Built-in testing mode  
- 🆔 3D ID tags  
- 🌍 Multi-language support  
- 🎨 Clean modern UI  

---

**DDCZ Scoreboard — Lightweight, professional and production ready. 🚀**
