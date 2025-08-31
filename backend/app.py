from flask import Flask, jsonify, request, render_template
from business import get_data

app = Flask(__name__)


@app.route('/')
def hello_world():

   
   return render_template('index.html')

@app.route('/api', methods=['GET'])
def api():

    data = get_data()

    data={
        'data': data
    }

    return jsonify(data)


if __name__=='__main__':
    app.run(host = '0.0.0.0', port=8000,debug=True)

