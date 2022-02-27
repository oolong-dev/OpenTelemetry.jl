from flask import Flask
from elasticapm.contrib.flask import ElasticAPM
import elasticapm

server_url = 'http://localhost:8200'
service_name = 'DemoFlask'
environment = 'dev'

app = Flask(__name__)
app.config['ELASTIC_APM'] = {
    'SERVICE_NAME': service_name,
    'DEBUG': True
}
apm = ElasticAPM(app, server_url=server_url)


@app.before_request
def apm_log():
    elasticapm.label(platform='DemoPlatform',
                     application='DemoApplication')


@app.route('/hello-world/')
def helloWorld():
    return "Hello World"


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
