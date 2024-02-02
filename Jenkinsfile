// Test pipeline

pipeline {
    environment {
        PATH="$WORKSPACE/src/gnu-devtools-for-arm:$WORKSPACE/src/gnu-devtools-for-arm/extras:$PATH"
        TOOLCHAIN_SRC_SPC_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/srcrel/arm-gnu-toolchain-src-snapshot-13.2.rel1-manifest.txt"
    }
    agent { label 'aarch64 && taishan' }
    options {
        // This is required so that we first clean the workspace and then we do the scm checkout
        skipDefaultCheckout(true)
    }
    stages {
        stage('Cleanup') {
            steps {
                // Clean before build and then checkout scm
                cleanWs()
                checkout scm
            }
        }
        stage('Check license') {
            steps {
                sshagent(credentials: ['dgboter-ssh']) {
                    script {
                        echo 'Checking license file...'
                    }
                }
            }
        }
        stage('Shellcheck') {
            steps {
                sh """\
                    echo "shellcheck ..."
                """

            }
        }
        stage('Native build') {
            steps {
                sshagent(credentials: ['dgboter-ssh']) {
                    sh """\
                        mkdir src
                        ln -s $WORKSPACE src/gnu-devtools-for-arm
                        wget $TOOLCHAIN_SRC_SPC_URL -O src/arm-gnu-toolchain-src-snapshot.txt
                        python3 extras/source-fetch.py checkout --srcdir src src/arm-gnu-toolchain-src-snapshot.txt
                        python3 extras/source-fetch.py checkout --srcdir src .additional_repos
 
                        build-gnu-toolchain.sh --target=aarch64-none-elf --builddir=$WORKSPACE/build
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

