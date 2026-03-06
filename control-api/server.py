from flask import Flask, jsonify, request
import json

app = Flask(__name__)

tasks = [
    {"task_id": 1, "target": "example.com"},
    {"task_id": 2, "target": "github.com"},
]

@app.route("/tasks/next")
def next_task():
    if tasks:
        return jsonify(tasks.pop(0))
    return jsonify({"task": None})

@app.route("/findings", methods=["POST"])
def findings():
    data = request.json
    print("Findings received:", data)
    return jsonify({"status": "stored"})

app.run(port=8080)