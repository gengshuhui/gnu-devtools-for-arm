
def devtools = [

        [
            id: 'B:aarch64 H:aarch64_none_linux_gnu T:aarch64-none-elf',
            label: 'aarch64 && docker && moonshot',
            params: '--target=aarch64-none-elf',
            path: null
        ]
    ]

def devtoolsBuildMap = devtools.collectEntries {
    ["${it}" : generateStage(it)]
}

def runAutoConf(directorys) {
    directorys.each { str ->
        dir(str) {
            sh"""
                autoreconf -i -f
            """
        }
    }
}

def generateStage(job) {
def stageVenv = "${params.BLD_PYTHON_ENV_PATH}"
    return {
        stage(job.id) {
            node ("${job.label}") {
                stage ("Clean up"){
                    cleanWs()
                }
                stage("Prepare Container") {
                    def uid = sh(script: 'id -u', returnStdout: true).trim()
                    def gid = sh(script: 'id -g', returnStdout: true).trim()
                    sh """
                        cp /etc/{group,passwd} $WORKSPACE
                        getent passwd ${localUser} >> passwd
                        getent group ${localUser} >> group
                    """
                    docker.withRegistry("https://${afGnuRegistry}/", 'gnuci-af-api-key') {
                        docker.image("${afGnuRegistry}/${dockerImgName}:latest").inside(" -v $WORKSPACE/passwd:/etc/passwd:ro -v $WORKSPACE/group:/etc/group:ro -v /home/${localUser}:/home/${localUser} -u ${uid}:${gid} -e HOME=/home/${localUser}") {
                            stage('Checkout') {
                                checkout scm
                            }
                            stage('build') {
                                sshagent(credentials: ['dgboter-ssh']) {
                                    
                                    sh """\
                                        mkdir -p src
                                        ln -s $WORKSPACE src/gnu-devtools-for-arm
                                        wget $TOOLCHAIN_SRC_SPC_URL -O arm-gnu-toolchain-src-snapshot.txt
                                        python3 extras/source-fetch.py checkout --shallow --srcdir src .additional_repos
                                    """
                                    runAutoConf(["$WORKSPACE/src/isl", "$WORKSPACE/src/libexpat/expat"])

                                    sh"""
                                        export PATH="${repo}:$PATH"
                                        python3 extras/source-fetch.py checkout --shallow --srcdir src arm-gnu-toolchain-src-snapshot.txt
                                        build-gnu-toolchain.sh ${job.params} --builddir=$WORKSPACE/build
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

pipeline {
    environment {
        def afGnuRegistry = 'dsg-gnu--docker.artifactory.geo.arm.com'
        def dockerImgName = 'build/ubu2204gnudevtools'
        def localUser = 'dgboter'
        def repo = "$WORKSPACE/src/gnu-devtools-for-arm"
        TOOLCHAIN_SRC_SPC_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/srcrel/arm-gnu-toolchain-src-snapshot-13.2.rel1-manifest.txt"
    }
    options {
        // This is required so that we first clean the workspace and then we do the scm checkout
        skipDefaultCheckout(true)
    }
    agent { label 'aarch64' }
    stages {
        stage('build') {
            steps {
                script {
                    // Generated parallel stages for builds
                    parallel devtoolsBuildMap
                }
            }
        }
    }
}
