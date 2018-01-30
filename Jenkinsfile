pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building sources..'
                pip install --user virtualenv
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
