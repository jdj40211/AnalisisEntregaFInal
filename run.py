from app.app import app

if __name__ == '__main__':
    # Port 5000 is occupied by macOS Control Center on Mac
    # Using port 5001 instead
    app.run(debug=True, port=5001)