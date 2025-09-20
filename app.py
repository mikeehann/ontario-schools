from flask import Flask, jsonify, render_template
import json

app = Flask(__name__)

with open('data/ontario_schools.geojson', 'r') as f:
    school_data = json.load(f)

@app.route('/')
def get_main():
    return render_template('index.html')


@app.route('/map-data')
def get_school_data():
    return jsonify(school_data)


if __name__ == '__main__':
    app.run(debug=True)