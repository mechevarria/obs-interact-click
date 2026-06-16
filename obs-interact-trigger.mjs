#!/usr/bin/env node
// Triggers an OBS frontend hotkey over obs-websocket (v5 protocol), bypassing
// OBS keyboard focus entirely. Reads host/port/password from OBS's own
// obs-websocket config so the password never has to live in this repo.
//
// Usage: node obs-interact-trigger.mjs [hotkeyName]
//   hotkeyName defaults to "obs_interact_click" (registered in obs-interact-click.lua)

import { createHash } from "crypto";
import { readFileSync } from "fs";
import { homedir } from "os";

const hotkeyName = process.argv[2] || "obs_interact_click";

const cfgPath = `${homedir()}/Library/Application Support/obs-studio/plugin_config/obs-websocket/config.json`;
const cfg = JSON.parse(readFileSync(cfgPath, "utf8"));
const { server_port: port, server_password: password } = cfg;

function sha256b64(str) {
    return createHash("sha256").update(str).digest("base64");
}

const ws = new WebSocket(`ws://127.0.0.1:${port}`);

const timeout = setTimeout(() => {
    console.error("Timed out waiting for OBS WebSocket — is OBS running?");
    process.exit(1);
}, 5000);

ws.onmessage = (ev) => {
    const msg = JSON.parse(ev.data);

    if (msg.op === 0) {
        // Hello
        const { challenge, salt } = msg.d.authentication;
        const secret = sha256b64(password + salt);
        const authResponse = sha256b64(secret + challenge);
        ws.send(JSON.stringify({
            op: 1, // Identify
            d: { rpcVersion: msg.d.rpcVersion, authentication: authResponse, eventSubscriptions: 0 },
        }));
    } else if (msg.op === 2) {
        // Identified
        ws.send(JSON.stringify({
            op: 6, // Request
            d: { requestType: "TriggerHotkeyByName", requestId: "1", requestData: { hotkeyName } },
        }));
    } else if (msg.op === 7) {
        // RequestResponse
        clearTimeout(timeout);
        if (!msg.d.requestStatus.result) {
            console.error("OBS request failed:", msg.d.requestStatus.comment || msg.d.requestStatus.code);
            ws.close();
            process.exit(1);
        }
        ws.close();
    }
};

ws.onerror = (ev) => {
    clearTimeout(timeout);
    console.error("WebSocket error — is the OBS WebSocket server enabled?", ev.message || ev);
    process.exit(1);
};
