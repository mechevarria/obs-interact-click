# obs-interact-click

Automates clicking inside an OBS browser source by opening the Interact window and sending a programmatic mouse click. Close the Interact window from an Elgato Stream Deck button using a companion Automator app (macOS). Main idea is to automate clicking on the spinwheel from a site like [wheeldecide.com](https://wheeldecide.com)

## Files

| File | Purpose |
|---|---|
| `obs-interact-click.lua` | OBS Lua script — opens Interact window and sends a click |
| `obs-interact-trigger.mjs` | Node script — triggers the click hotkey over obs-websocket (no OBS focus required) |

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

**2. Create an Automator Application**

1. Open **Automator** (`/Applications/Automator.app`)
2. **File > New**, choose **Application**
3. In the action library, search for `Run Shell Script` and drag it into the workflow
4. Set **Shell** to `/bin/zsh` and **Pass input** to `to stdin`
5. Replace the default script body with:
   ```sh
   /opt/homebrew/bin/node "/full/path/to/obs-interact-trigger.mjs"
   ```
   Replace `/full/path/to/` with the actual absolute path to this repo.
6. **File > Save** — name it e.g. `OBS Interact Trigger` and save it to the repo folder or `~/Applications/`

**3. Add to Stream Deck**

- In the Stream Deck app, add an **Open** action to a button
- Set the file path to the `.app` you saved above

No OBS Settings configuration is needed for this path — the script calls the action directly by its registered name (`obs_interact_click`, set in `obs-interact-click.lua`).

---

## Part 2 — Close Script

### What it does

Finds the OBS Interact window (any window whose title starts with `"Interacting with "`) and clicks its close button using macOS Accessibility APIs via AppleScript.

### Setup

**1. Create an Automator Application**

1. Open **Automator** (`/Applications/Automator.app`)
2. **File > New**, choose **Application**
3. In the action library, search for `Run Shell Script` and drag it into the workflow
4. Set **Shell** to `/bin/zsh` and **Pass input** to `to stdin`
5. Replace the default script body with:
   ```sh
   osascript <<'SCRIPT'
   tell application "System Events"
       tell process "OBS"
           repeat with w in windows
               if name of w starts with "Interacting with " then
                   click button 1 of w
                   exit repeat
               end if
           end repeat
       end tell
   end tell
   SCRIPT
   ```
6. **File > Save** — name it e.g. `OBS Interact Close` and save it to the repo folder or `~/Applications/`

**2. Grant Accessibility permission**

The AppleScript in this app needs Accessibility access to click the OBS window. Open **System Settings > Privacy & Security > Accessibility**, click **+**, and add the `.app` you saved above.

> **Troubleshooting:** If you see `osascript is not allowed assistive access. (-25211)`, the app is missing from the Accessibility list — add it as described above. Note that saving a new version of the Automator app may revoke the grant; re-add it if the error reappears.

**3. Add to Stream Deck**

- In the Stream Deck app, add an **Open** action to a button
- Set the file path to the `.app` you saved above

---

## Typical Workflow

| Step | Action | How |
|---|---|---|
| 1 | Trigger interact & click | Stream Deck button → Automator app → `obs-interact-trigger.mjs` → websocket → `obs-interact-click.lua` |
| 2 | OBS opens Interact window | Automatic |
| 3 | Script clicks browser source | Automatic (200 ms after window opens) |
| 4 | Close Interact window | Stream Deck button → Automator app → AppleScript closes OBS Interact window |
