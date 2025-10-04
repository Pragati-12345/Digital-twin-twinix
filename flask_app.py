from flask import Flask, jsonify, request
import subprocess
import json
import chatbot_main

app = Flask(_name_)

@app.route('/query', methods=['POST'])
def query():
    data = request.json
    user_query = data.get('query','')

    # AI chatbot response
    reply = chatbot_main.get_response(user_query)

    # MATLAB digital twin call
    result = subprocess.run(["matlab","-batch","digitalTwin"], capture_output=True, text=True)
    try:
        matlab_output = json.loads(result.stdout)
    except:
        matlab_output = {"error":"MATLAB output not parsed"}

    response = {"reply": reply, "digitalTwin": matlab_output}
    return jsonify(response)

if _name=="main_":
    app.run(host="0.0.0.0", port=5000)