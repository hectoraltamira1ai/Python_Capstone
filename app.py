from flask import Flask, render_template, jsonify
import threading
import time
import random
import os

app = Flask(__name__)

BOX_COUNT = 8
MAX_COUNT = 50
LOCK = threading.Lock()

# Random start values (0..49)
COUNTERS = [random.randint(0, MAX_COUNT - 1) for _ in range(BOX_COUNT)]


def counter_loop():
    while True:
        with LOCK:
            for i in range(len(COUNTERS)):
                COUNTERS[i] += 1
                if COUNTERS[i] > MAX_COUNT:
                    COUNTERS[i] = 0
        time.sleep(1)


@app.route("/")
def index():
    return render_template("index.html", box_count=BOX_COUNT, max_count=MAX_COUNT)


@app.route("/api/counters")
def get_counters():
    with LOCK:
        return jsonify({
            "max": MAX_COUNT,
            "values": COUNTERS
        })


if __name__ == "__main__":
    # Avoid double-thread in Flask debug reloader
    if os.environ.get("WERKZEUG_RUN_MAIN") == "true":
        threading.Thread(target=counter_loop, daemon=True).start()

    app.run(debug=True, port=5001)