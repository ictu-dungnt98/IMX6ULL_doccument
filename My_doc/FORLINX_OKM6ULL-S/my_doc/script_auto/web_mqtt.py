#!/usr/bin/env python3
import cgi
import html
import json
import os
import subprocess
import threading
from datetime import datetime
from http.server import BaseHTTPRequestHandler, SimpleHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs

HOST       = "0.0.0.0"
PORT       = 8080
FILE_PORT  = 8888
OTA_DIR    = "/tmp/ota_files"

MQTT_HOST  = "192.168.1.66"
MQTT_PORT  = "1883"
MQTT_TOPIC = "test/topic"

import socket
def get_host_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "192.168.1.66"

HOST_IP = get_host_ip()

COMMANDS = [
    ("hello board", "Hello"),
    ("led on",      "LED ON"),
    ("led off",     "LED OFF"),
    ("led toggle",  "Toggle"),
    ("led blink",   "Blink"),
    ("status",      "Status"),
]

OTA_TYPES = [
    ("app",    "app",    "📦", "Binary app (mqtt_led_app)",      "#7c3aed"),
    ("kernel", "kernel", "🐧", "Kernel (zImage)",                "#b45309"),
    ("config", "config", "⚙️",  "Config file",                   "#0b6bcb"),
    ("rootfs", "rootfs", "💾", "Root filesystem",                "#b42318"),
]

history = []

# =========================================================
# File server nền
# =========================================================
os.makedirs(OTA_DIR, exist_ok=True)

class _OTAFileHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=OTA_DIR, **kwargs)
    def log_message(self, fmt, *args):
        pass

threading.Thread(
    target=lambda: ThreadingHTTPServer(("0.0.0.0", FILE_PORT), _OTAFileHandler).serve_forever(),
    daemon=True
).start()

# =========================================================
# MQTT publish
# =========================================================
def publish_mqtt(message):
    cmd = ["mosquitto_pub", "-h", MQTT_HOST, "-p", MQTT_PORT, "-t", MQTT_TOPIC, "-m", message]
    result = subprocess.run(cmd, text=True, capture_output=True, timeout=5)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "mosquitto_pub failed")

# =========================================================
# HTML
# =========================================================
def page(status="", error=""):
    rows = "\n".join(
        f"""<tr>
          <td>{html.escape(item["time"])}</td>
          <td><code>{html.escape(item["topic"])}</code></td>
          <td>{html.escape(item["message"])}</td>
          <td class="state-{html.escape(item['state'])}">{html.escape(item["state"])}</td>
        </tr>"""
        for item in reversed(history[-20:])
    )
    buttons = "\n".join(
        f'<button type="submit" name="message" value="{html.escape(v)}">{html.escape(l)}</button>'
        for v, l in COMMANDS
    )
    uploaded_files = sorted(os.listdir(OTA_DIR)) if os.path.isdir(OTA_DIR) else []
    file_list_html = ""
    if uploaded_files:
        chips = "".join(f'<span class="file-chip">{html.escape(f)}</span>' for f in uploaded_files)
        file_list_html = f'<div class="file-list"><div class="file-list-title">📁 Files on server ({html.escape(HOST_IP)}:{FILE_PORT}):</div>{chips}</div>'

    # OTA type cards
    type_cards_upload = "\n".join(
        f'''<label class="type-card" onclick="selectType('upload','{v}',this)">
              <input type="radio" name="ota_type" value="{v}" {"checked" if v=="app" else ""}>
              <span class="type-icon">{icon}</span>
              <span class="type-name">{l}</span>
              <span class="type-desc">{desc}</span>
            </label>'''
        for v, l, icon, desc, color in OTA_TYPES
    )
    type_cards_url = "\n".join(
        f'''<label class="type-card" onclick="selectType('url','{v}',this)" id="url-type-{v}">
              <input type="radio" name="ota_type" value="{v}" {"checked" if v=="app" else ""}>
              <span class="type-icon">{icon}</span>
              <span class="type-name">{l}</span>
              <span class="type-desc">{desc}</span>
            </label>'''
        for v, l, icon, desc, color in OTA_TYPES
    )

    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>IMX6ULL MQTT Control</title>
  <style>
    :root{{--bg:#f4f7fb;--panel:#fff;--text:#172033;--muted:#667085;--line:#d9e1ec;--accent:#0b6bcb;--accent-dark:#084f96;--danger:#b42318;--ok:#067647;}}
    *{{box-sizing:border-box;}}
    body{{margin:0;font-family:Arial,sans-serif;background:var(--bg);color:var(--text);}}
    main{{width:min(980px,calc(100% - 32px));margin:0 auto;padding:28px 0;}}
    header{{display:flex;justify-content:space-between;align-items:flex-end;gap:16px;margin-bottom:18px;}}
    h1{{margin:0;font-size:28px;}}
    .meta{{color:var(--muted);font-size:14px;text-align:right;line-height:1.6;}}
    section{{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:18px;margin-bottom:16px;}}
    h2{{margin:0 0 14px;font-size:18px;}}
    .quick{{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;margin-bottom:16px;}}
    button{{min-height:42px;border:0;border-radius:6px;background:var(--accent);color:#fff;font-weight:700;cursor:pointer;font-size:14px;}}
    button:hover{{background:var(--accent-dark);}}
    .custom{{display:flex;gap:10px;}}
    input[type=text]{{flex:1;min-width:0;min-height:42px;border:1px solid var(--line);border-radius:6px;padding:0 12px;font-size:15px;width:100%;}}
    .notice{{margin-bottom:16px;padding:12px 14px;border-radius:6px;background:#eaf4ff;color:#084f96;}}
    .error{{margin-bottom:16px;padding:12px 14px;border-radius:6px;background:#fff1f0;color:var(--danger);}}

    /* OTA */
    .ota-badge{{display:inline-block;background:#7c3aed;color:#fff;font-size:11px;font-weight:700;padding:2px 8px;border-radius:20px;margin-left:8px;vertical-align:middle;}}
    .ota-tabs{{display:flex;gap:8px;margin-bottom:16px;}}
    .ota-tab{{min-height:36px;border:2px solid var(--line);background:#fff;color:var(--muted);border-radius:6px;padding:0 16px;font-weight:700;font-size:14px;cursor:pointer;}}
    .ota-tab.active{{border-color:#7c3aed;background:#7c3aed;color:#fff;}}
    .ota-panel{{display:none;}}.ota-panel.active{{display:block;}}

    /* Type cards */
    .type-cards{{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:16px;}}
    .type-card{{border:2px solid var(--line);border-radius:8px;padding:12px 8px;cursor:pointer;text-align:center;transition:all .15s;background:#fafafa;}}
    .type-card:has(input:checked){{border-color:#7c3aed;background:#faf5ff;}}
    .type-card input{{display:none;}}
    .type-icon{{display:block;font-size:24px;margin-bottom:4px;}}
    .type-name{{display:block;font-weight:700;font-size:14px;}}
    .type-desc{{display:block;font-size:11px;color:var(--muted);margin-top:2px;}}

    /* Kernel warning */
    .kernel-warn{{display:none;background:#fffbeb;border:1px solid #f59e0b;border-radius:6px;padding:10px 14px;margin-bottom:12px;color:#92400e;font-size:13px;}}
    .kernel-warn.show{{display:block;}}

    .ota-grid{{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;}}
    .ota-grid .full{{grid-column:1/-1;}}
    .field-group{{display:flex;flex-direction:column;gap:5px;}}
    .field-group label{{font-size:13px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;}}
    .field-group input[type=text]{{min-height:40px;}}
    .ota-preview{{background:#1e1e2e;color:#cdd6f4;border-radius:6px;padding:12px 14px;font-family:monospace;font-size:13px;margin-bottom:12px;white-space:pre-wrap;word-break:break-all;border:1px solid #313244;}}
    .ota-preview .key{{color:#89b4fa;}}.ota-preview .str{{color:#a6e3a1;}}
    .btn-ota{{background:#7c3aed;min-height:46px;font-size:15px;width:100%;margin-top:4px;}}
    .btn-ota:hover{{background:#5b21b6;}}
    .btn-ota.kernel{{background:#b45309;}}.btn-ota.kernel:hover{{background:#92400e;}}

    .upload-zone{{border:2px dashed #7c3aed;border-radius:8px;padding:28px;text-align:center;cursor:pointer;background:#faf5ff;margin-bottom:12px;transition:background .2s;}}
    .upload-zone:hover{{background:#f3e8ff;}}
    .upload-zone input{{display:none;}}
    .upload-zone .icon{{font-size:36px;margin-bottom:8px;}}
    .upload-zone .hint{{color:var(--muted);font-size:14px;}}
    .upload-zone .fname{{color:#7c3aed;font-weight:700;font-size:15px;margin-top:6px;}}
    .file-list{{margin-bottom:12px;}}
    .file-list-title{{font-size:13px;font-weight:700;color:var(--muted);margin-bottom:6px;}}
    .file-chip{{display:inline-block;background:#f3e8ff;color:#7c3aed;border:1px solid #e9d5ff;border-radius:20px;padding:3px 10px;font-size:13px;margin:3px;}}
    .upload-meta{{display:grid;grid-template-columns:1fr;gap:12px;margin-bottom:12px;}}

    table{{width:100%;border-collapse:collapse;font-size:14px;}}
    th,td{{padding:10px 8px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top;}}
    th{{color:var(--muted);font-weight:700;}}
    code{{background:#eef2f7;padding:2px 5px;border-radius:4px;}}
    .state-sent{{color:var(--ok);font-weight:700;}}
    .state-failed{{color:var(--danger);font-weight:700;}}
    .state-ota-sent{{color:#7c3aed;font-weight:700;}}
    .state-ota-kernel{{color:#b45309;font-weight:700;}}

    @media(max-width:640px){{
      .type-cards{{grid-template-columns:repeat(2,1fr);}}
      header,.custom{{display:block;}}
      .meta{{text-align:left;margin-top:8px;}}
    }}
  </style>
</head>
<body>
<main>
  <header>
    <div><h1>IMX6ULL MQTT Control</h1></div>
    <div class="meta">
      Broker: <code>{html.escape(MQTT_HOST)}:{html.escape(MQTT_PORT)}</code><br>
      Topic: <code>{html.escape(MQTT_TOPIC)}</code><br>
      File server: <code>{html.escape(HOST_IP)}:{FILE_PORT}</code>
    </div>
  </header>

  {f'<div class="notice">{html.escape(status)}</div>' if status else ''}
  {f'<div class="error">{html.escape(error)}</div>'   if error  else ''}

  <!-- Quick Commands -->
  <section>
    <h2>Quick Commands</h2>
    <form method="post"><div class="quick">{buttons}</div></form>
    <form class="custom" method="post">
      <input type="text" name="message" placeholder="Type command payload" autocomplete="off" required>
      <button type="submit">Send</button>
    </form>
  </section>

  <!-- OTA -->
  <section>
    <h2>OTA Update <span class="ota-badge">FIRMWARE</span></h2>
    <div class="ota-tabs">
      <button type="button" class="ota-tab active" onclick="switchTab('upload')">📁 Upload File</button>
      <button type="button" class="ota-tab"        onclick="switchTab('url')">🔗 URL</button>
    </div>

    <!-- Tab Upload -->
    <div class="ota-panel active" id="tab-upload">
      <form method="post" enctype="multipart/form-data">
        <div class="type-cards" id="upload-type-cards">
          {type_cards_upload}
        </div>
        <div class="kernel-warn" id="upload-kernel-warn">
          ⚠️ <strong>Kernel OTA nguy hiểm!</strong> Sai kernel → board không boot được.
          Board sẽ tự backup <code>zImage.bak</code> trước khi replace. Chắc chắn trước khi gửi!
        </div>
        <div class="upload-zone" onclick="document.getElementById('file-input').click()">
          <input type="file" name="ota_file" id="file-input" onchange="onFileSelect(this)">
          <div class="icon" id="upload-icon">📦</div>
          <div id="upload-hint">Click để chọn file firmware</div>
          <div class="hint">Binary, zImage, .sh, .tar.gz ...</div>
          <div class="fname" id="fname-label"></div>
        </div>
        {file_list_html}
        <div class="upload-meta">
          <div class="field-group">
            <label>Version</label>
            <input type="text" name="ota_version" placeholder="vd: 1.0.2" value="1.0.0" required>
          </div>
        </div>
        <button type="submit" class="btn-ota" id="btn-upload-ota" name="ota_upload" value="1">
          🚀 Upload &amp; Send OTA
        </button>
      </form>
    </div>

    <!-- Tab URL -->
    <div class="ota-panel" id="tab-url">
      <form method="post">
        <div class="type-cards" id="url-type-cards">
          {type_cards_url}
        </div>
        <div class="kernel-warn" id="url-kernel-warn">
          ⚠️ <strong>Kernel OTA nguy hiểm!</strong> Sai kernel → board không boot được.
          Board sẽ tự backup <code>zImage.bak</code> trước khi replace. Chắc chắn trước khi gửi!
        </div>
        <div class="ota-grid">
          <div class="field-group">
            <label>Version</label>
            <input type="text" name="ota_version" id="ota_version"
                   placeholder="vd: 1.0.2" value="1.0.0" oninput="updatePreview()" required>
          </div>
          <div class="field-group">
            <label>&nbsp;</label>
            <div style="font-size:13px;color:var(--muted);padding-top:10px;" id="url-type-hint">
              Type: <strong>app</strong>
            </div>
          </div>
          <div class="field-group full">
            <label>Download URL</label>
            <input type="text" name="ota_url" id="ota_url"
                   placeholder="http://192.168.1.x:8888/mqtt_led_app"
                   oninput="updatePreview()" required>
          </div>
        </div>
        <div class="ota-preview" id="ota-preview"></div>
        <button type="submit" class="btn-ota" id="btn-url-ota" name="ota_submit" value="1">
          🚀 Send OTA Update
        </button>
        <!-- hidden field cho type -->
        <input type="hidden" name="ota_type" id="ota_type_hidden" value="app">
      </form>
    </div>
  </section>

  <!-- History -->
  <section>
    <h2>Send History</h2>
    <table>
      <thead><tr><th>Time</th><th>Topic</th><th>Message</th><th>State</th></tr></thead>
      <tbody>{rows or '<tr><td colspan="4">No commands sent yet.</td></tr>'}</tbody>
    </table>
  </section>
</main>

<script>
// ── Tab switch ──────────────────────────────────────────
function switchTab(name) {{
  document.querySelectorAll('.ota-tab').forEach((t,i) =>
    t.classList.toggle('active', (name==='upload'&&i===0)||(name==='url'&&i===1)));
  document.getElementById('tab-upload').classList.toggle('active', name==='upload');
  document.getElementById('tab-url').classList.toggle('active',    name==='url');
}}

// ── Type card select ─────────────────────────────────────
let currentUploadType = 'app';
let currentUrlType    = 'app';

const TYPE_INFO = {{
  app:    {{ icon:'📦', label:'app',    btn:'🚀 Upload & Send OTA',    btnClass:'btn-ota' }},
  kernel: {{ icon:'🐧', label:'kernel', btn:'⚠️ Upload & Send Kernel OTA', btnClass:'btn-ota kernel' }},
  config: {{ icon:'⚙️',  label:'config', btn:'🚀 Upload & Send OTA',    btnClass:'btn-ota' }},
  rootfs: {{ icon:'💾', label:'rootfs', btn:'🚀 Upload & Send OTA',    btnClass:'btn-ota' }},
}};

function selectType(tab, val, el) {{
  // Uncheck others in same group
  el.closest('.type-cards').querySelectorAll('.type-card').forEach(c => c.style.outline = '');

  if (tab === 'upload') {{
    currentUploadType = val;
    const warn = document.getElementById('upload-kernel-warn');
    warn.classList.toggle('show', val === 'kernel');
    const btn = document.getElementById('btn-upload-ota');
    btn.textContent = TYPE_INFO[val].btn;
    btn.className   = TYPE_INFO[val].btnClass;
    document.getElementById('upload-icon').textContent = TYPE_INFO[val].icon;
  }} else {{
    currentUrlType = val;
    document.getElementById('ota_type_hidden').value = val;
    const warn = document.getElementById('url-kernel-warn');
    warn.classList.toggle('show', val === 'kernel');
    const btn = document.getElementById('btn-url-ota');
    btn.textContent = TYPE_INFO[val].btn;
    btn.className   = TYPE_INFO[val].btnClass;
    document.getElementById('url-type-hint').innerHTML = 'Type: <strong>' + val + '</strong>';
    updatePreview();
  }}
}}

function onFileSelect(input) {{
  const label = document.getElementById('fname-label');
  label.textContent = input.files[0] ? '✅ ' + input.files[0].name : '';
}}

function updatePreview() {{
  const type    = currentUrlType;
  const version = document.getElementById('ota_version')?.value || '';
  const url     = document.getElementById('ota_url')?.value     || '';
  const s = JSON.stringify({{cmd:'ota', type, version, url}}, null, 2);
  document.getElementById('ota-preview').innerHTML =
    s.replace(/"([^"]+)":/g, '<span class="key">"$1"</span>:')
     .replace(/: "([^"]*)"/g, ': <span class="str">"$1"</span>');
}}
updatePreview();
</script>
</body>
</html>"""

# =========================================================
# Handler
# =========================================================
class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        self._send_html(page())

    def do_POST(self):
        ct = self.headers.get("Content-Type", "")

        # ── Upload file ──────────────────────────────────────
        if "multipart/form-data" in ct:
            form = cgi.FieldStorage(fp=self.rfile, headers=self.headers,
                                    environ={"REQUEST_METHOD":"POST","CONTENT_TYPE":ct})
            if "ota_upload" not in form:
                self._send_html(page(error="No upload action"), status=400); return

            ota_file    = form["ota_file"]
            ota_type    = form.getvalue("ota_type",    "app")
            ota_version = form.getvalue("ota_version", "1.0.0").strip()

            if not ota_file.filename:
                self._send_html(page(error="No file selected"), status=400); return

            fname     = os.path.basename(ota_file.filename)
            save_path = os.path.join(OTA_DIR, fname)
            with open(save_path, "wb") as f:
                f.write(ota_file.file.read())
            os.chmod(save_path, 0o755)

            file_url = f"http://{HOST_IP}:{FILE_PORT}/{fname}"
            payload  = json.dumps({
                "cmd":     "ota",
                "type":    ota_type,
                "version": ota_version,
                "url":     file_url,
            })

            state = "ota-kernel" if ota_type == "kernel" else "ota-sent"
            item  = {
                "time":    datetime.now().strftime("%H:%M:%S"),
                "topic":   MQTT_TOPIC,
                "message": f"[OTA-{ota_type.upper()}] {fname} ver={ota_version}",
                "state":   state,
            }
            try:
                publish_mqtt(payload)
                history.append(item)
                icon = "⚠️" if ota_type == "kernel" else "✅"
                self._send_html(page(status=f"{icon} OTA {ota_type} '{fname}' v{ota_version} sent → {file_url}"))
            except Exception as exc:
                item["state"] = "failed"; history.append(item)
                self._send_html(page(error=str(exc)), status=500)
            return

        # ── URL / Normal ─────────────────────────────────────
        length = int(self.headers.get("Content-Length", "0"))
        body   = self.rfile.read(length).decode("utf-8", errors="replace")
        data   = parse_qs(body)

        if data.get("ota_submit"):
            ota_type    = data.get("ota_type",    ["app"])[0].strip()
            ota_version = data.get("ota_version", [""])[0].strip()
            ota_url     = data.get("ota_url",     [""])[0].strip()
            if not ota_version or not ota_url:
                self._send_html(page(error="Version and URL are required"), status=400); return

            payload = json.dumps({
                "cmd":     "ota",
                "type":    ota_type,
                "version": ota_version,
                "url":     ota_url,
            })
            state = "ota-kernel" if ota_type == "kernel" else "ota-sent"
            item  = {
                "time":    datetime.now().strftime("%H:%M:%S"),
                "topic":   MQTT_TOPIC,
                "message": f"[OTA-{ota_type.upper()}] ver={ota_version}",
                "state":   state,
            }
            try:
                publish_mqtt(payload); history.append(item)
                icon = "⚠️" if ota_type == "kernel" else "✅"
                self._send_html(page(status=f"{icon} OTA {ota_type} v{ota_version} sent"))
            except Exception as exc:
                item["state"] = "failed"; history.append(item)
                self._send_html(page(error=str(exc)), status=500)
            return

        message = data.get("message", [""])[0].strip()
        if not message:
            self._send_html(page(error="Message is empty"), status=400); return
        item = {"time":datetime.now().strftime("%H:%M:%S"),"topic":MQTT_TOPIC,
                "message":message,"state":"sent"}
        try:
            publish_mqtt(message); history.append(item)
            self._send_html(page(status=f"Sent: {message}"))
        except Exception as exc:
            item["state"] = "failed"; history.append(item)
            self._send_html(page(error=str(exc)), status=500)

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args))

    def _send_html(self, content, status=200):
        data = content.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Web MQTT control : http://127.0.0.1:{PORT}")
    print(f"OTA file server  : http://{HOST_IP}:{FILE_PORT}/")
    print(f"MQTT broker      : {MQTT_HOST}:{MQTT_PORT} → {MQTT_TOPIC}")
    server.serve_forever()

if __name__ == "__main__":
    main()