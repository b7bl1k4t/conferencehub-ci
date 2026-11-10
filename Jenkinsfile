pipeline {
    agent any
    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }
    parameters {
        string(name: 'NOTIFY_EMAIL', defaultValue: '',
               description: 'Optional recipient; configure SMTP first')
    }
    environment {
        APP_NAME = 'ConferenceHub'
        DEPLOY_ROOT = "${env.JENKINS_HOME}/pr4-deploy/conferencehub"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --format="%h %s"'
            }
        }
        stage('Build') {
            steps { sh 'sh build.sh' }
        }
        stage('Test') {
            steps { sh 'sh test.sh' }
        }
        stage('Deploy to Staging') {
            steps { sh 'sh deploy staging' }
        }
        stage('Smoke Tests') {
            steps { sh 'sh smoke-tests staging' }
        }
        stage('Approval') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: 'Promote ConferenceHub to simulated production?',
                          ok: 'Deploy'
                }
            }
        }
        stage('Deploy to Production') {
            steps {
                sh 'sh deploy prod'
                sh 'sh smoke-tests prod'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'dist/*.txt',
                             fingerprint: true, allowEmptyArchive: true
        }
        success { echo 'SUCCESS: simulated release verified in staging and prod' }
        failure {
            echo "FAILURE: inspect ${env.BUILD_URL}console"
            script {
                if (params.NOTIFY_EMAIL?.trim()) {
                    mail to: params.NOTIFY_EMAIL.trim(),
                         subject: "${env.JOB_NAME} #${env.BUILD_NUMBER}: FAILURE",
                         body: "Console: ${env.BUILD_URL}console"
                }
            }
        }
        aborted { echo 'ABORTED: pipeline interrupted or approval timed out' }
        cleanup { deleteDir() }
    }
}
