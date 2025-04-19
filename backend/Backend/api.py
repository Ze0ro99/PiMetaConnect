"""
API module for PiMetaConnect backend.

This module provides endpoints for connecting and checking the status of the PiMetaConnect service.
"""

from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/api/connect', methods=['POST'])
def connect():
    """
    Handle API connection requests.

    Returns:
        JSON response with a success message and provided data.
    """
    data = request.json
    return jsonify({"message": "تم الاتصال بنجاح!", "data": data})

@app.route('/api/status', methods=['GET'])
def status():
    """
    Handle API status check requests.

    Returns:
        JSON response indicating the service status.
    """
    return jsonify({"message": "خدمة MetaConnect تعمل بشكل جيد!"})

if __name__ == '__main__':
    app.run()
