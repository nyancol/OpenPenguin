pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building sources..'
                sh '''pip install --user virtualenv
                virtualenv venv -p python3
                source venv/bin/activate
                pip install flask
                pip install requests
                pip install pika
                pip install python-swiftclient
                pip install redis'''
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying..'
            }
        }
    }
}
