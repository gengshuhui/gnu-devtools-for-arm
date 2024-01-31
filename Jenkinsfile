// Test pipeline

pipeline {
    agent { label 'aarch64' }
    stages {
        stage('Check license') {
            steps {
                cleanWs()
                sshagent(credentials: ['dgboter-ssh']) {
                    script {
                        echo 'Checking license file...'
                    }
                }
            }
        }
        stage('Shellcheck') {
            steps {
                cleanWs()
                sh """\
                    echo "shellcheck ..."
                """

            }
        }
        stage('Native build') {
            steps {
                cleanWs()
                sshagent(credentials: ['dgboter-ssh']) {
                    sh """\
                       echo "./build-me.sh ..."
                    """
                }
            }
        }
        stage('Out Of Box Testing') {
            steps {
                sshagent(credentials: ['dgboter-ssh']) {
                    sh """\
                        echo "Run tests"
                    """
                }
            }
        }

    }
}

