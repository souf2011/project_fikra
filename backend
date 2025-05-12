rom flask import Flask, request, jsonify, send_file
from flask_cors import CORS

import os
import uuid


app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
PROCESSED_FOLDER = 'processed'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

@app.route('/remove_noise', methods=['POST'])
def remove_noise():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    filename = f"{uuid.uuid4()}.wav"
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)


    audio = AudioSegment.from_file(filepath)
    processed_audio = audio + 10  # +10 dB = plus fort

    processed_path = os.path.join(PROCESSED_FOLDER, filename)
    processed_audio.export(processed_path, format="wav")

    return send_file(processed_path, as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
