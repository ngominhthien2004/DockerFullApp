from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def root():
    return '<h1>Python app running inside combined image</h1><p>Access via VNC or visit /api</p>'

@app.route('/api')
def api():
    return jsonify({'status':'ok','service':'python'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
