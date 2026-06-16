# obs-interact-click

Automates clicking inside an OBS browser source by opening the Interact window and sending a programmatic mouse click. Close the Interact window from an Elgato Stream Deck button using a companion bash script (mac specific). Main idea is to automate clicking on the spinwheel from a site like [wheeldecide.com](https://wheeldecide.com)

## Files

| File | Purpose |
|---|---|
| `obs-interact-click.lua` | OBS Lua script — opens Interact window and sends a click |
| `obs-interact-close.command` | Bash script — closes the Interact window via AppleScript |
| `obs-interact-trigger.mjs` | Node script — triggers the click hotkey over obs-websocket (no OBS focus required) |
| `obs-interact-trigger.command` | Stream Deck entry point for `obs-interact-trigger.mjs` |

![OBS Interact window open for a browser source](example.png)

---

## Part 1 — OBS Lua Script (`obs-interact-click.lua`)

### What it does

1. Opens the OBS Interact window for a selected browser source
2. Waits 200 ms for the window to appear
3. Sends a left mouse click at the configured (X, Y) coordinates within the browser source

### Setup

**1. Load the script in OBS**

- Open OBS → **Tools > Scripts**
- Click **+** and select `obs-interact-click.lua`

**2. Configure the script**

In the Scripts panel:

- **Browser Source** — select the browser source you want to interact with from the dropdown
- **Click X / Click Y** — pixel coordinates within the browser source canvas (e.g. for a 1920×1080 source, values range from 0–1920 and 0–1080)

> **Tip:** Use the **"Interact & Click"** button in the Scripts panel to test the action. To trigger it from a Stream Deck button, see [Part 1b](#part-1b--websocket-trigger-obs-interact-triggermjs).

---

## Part 1b — WebSocket Trigger (`obs-interact-trigger.mjs`)

### What it does

Triggers the `obs_interact_click` action registered by `obs-interact-click.lua` over [obs-websocket](https://github.com/obsproject/obs-websocket) (built into OBS 28+). This bypasses OS-level keyboard focus entirely — the click fires no matter what app or window is currently active.

### Dependencies

- **Node.js 22+** — uses the native `WebSocket` global, no npm packages required. Install via Homebrew:

  ```bash
  brew install node
  ```

### Setup

**1. Enable the WebSocket server**

- OBS → **Tools > obs-websocket Settings**
- Check **Enable WebSocket server**, note the port (default `4455`)
- A password is generated automatically — `obs-interact-trigger.mjs` reads it directly from OBS's own config file (`~/Library/Application Support/obs-studio/plugin_config/obs-websocket/config.json`), so it never needs to be copied anywhere

**2. Make the wrapper executable**

```bash
chmod +x obs-interact-trigger.command obs-interact-trigger.mjs
```

**3. Add to Stream Deck**

- In the Stream Deck app, add an **Open** action to a button
- Set the file path to `obs-interact-trigger.command`

No OBS Settings configuration is needed for this path — the script calls the action directly by its registered name (`obs_interact_click`, set in `obs-interact-click.lua`).

---

## Part 2 — Close Script (`obs-interact-close.command`)

### What it does

Finds the OBS Interact window (any window whose title starts with `"Interacting with "`) and clicks its close button using macOS Accessibility APIs via AppleScript. Closes its own Terminal window immediately afterward so it doesn't linger on screen.

> macOS only. Requires Accessibility permission for Terminal (or whichever app runs the script).

### Setup

**1. Make the script executable**

```bash
chmod +x obs-interact-close.command
```

**2. Grant Accessibility permission**

The first time the script runs, macOS will prompt to grant Accessibility access to Terminal (or Script Editor). Approve it under:

**System Settings > Privacy & Security > Accessibility**

> **Troubleshooting:** If you see `osascript is not allowed assistive access. (-25211)`, macOS didn't prompt automatically (or the grant got reset, e.g. after a Terminal update). Open the Accessibility pane above and check whether **Terminal** is listed and toggled on — if it's missing, click **+** and add `/Applications/Utilities/Terminal.app`. If Stream Deck launches the script without spawning a visible Terminal, add **Stream Deck** to the list too. Restart Terminal after granting access.

**3. Add to Stream Deck**

- In the Stream Deck app, add an **Open** action to a button
- Set the file path to `obs-interact-close.command`

---

## Typical Workflow

| Step | Action | How |
|---|---|---|
| 1 | Trigger interact & click | Stream Deck button → `obs-interact-trigger.command` → websocket → `obs-interact-click.lua` |
| 2 | OBS opens Interact window | Automatic |
| 3 | Script clicks browser source | Automatic (200 ms after window opens) |
| 4 | Close Interact window | Stream Deck button → `obs-interact-close.command` |
