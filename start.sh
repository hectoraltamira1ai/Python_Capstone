#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT=5001
URL="http://127.0.0.1:${PORT}"

# Create venv if missing
if [[ ! -d ".venv" ]]; then
  python3 -m venv .venv
fi

# Activate and ensure Flask is installed
source .venv/bin/activate
python -m pip install --upgrade pip >/dev/null
python -m pip install flask >/dev/null

open_chrome_tab() {
osascript <<EOF
if application "Google Chrome" is running then
    tell application "Google Chrome"
        activate
        if (count of windows) = 0 then
            make new window
        end if
        tell front window
            make new tab with properties {URL:"$URL"}
            set active tab index to (count of tabs)
        end tell
    end tell
else
    do shell script "open -a 'Google Chrome' '$URL'"
end if
EOF
}

# Wait for server, then open Chrome tab
(
  for _ in {1..40}; do
    if curl -fsS "$URL" >/dev/null 2>&1; then
      open_chrome_tab
      exit 0
    fi
    sleep 0.25
  done
) &

# Run Flask in foreground
exec python app.py

# ...existing code...

DEBUG = True

if __name__ == "__main__":
    if (not DEBUG) or (os.environ.get("WERKZEUG_RUN_MAIN") == "true"):
        threading.Thread(target=counter_loop, daemon=True).start()

    app.run(debug=DEBUG, port=5001)

