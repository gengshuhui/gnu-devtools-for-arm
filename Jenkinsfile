
// cplatforms: linux/arm64, linux/arm/v7, linux/amd64
def devtools = [
        // baremetal targets
        [
            id: 'H:aarch64_none_linux_gnu T:aarch64_none_elf',
            label: 'aarch64 && docker',
            params: '--target=aarch64-none-elf -- --host=aarch64-none-linux-gnu --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:aarch64_none_elf',
            label: 'rhe8 && x86_64 && docker',
            params: '--target=aarch64-none-elf -- --host=x86_64-none-linux-gnu --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ],
        [
            id: 'H:aarch64_none_linux_gnu T:arm_none_eabi',
            label: 'aarch64 && docker',
            params: '--target=arm-none-eabi --aprofile -- --host=aarch64-none-linux-gnu --release --package --enable-newlib-nano --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:arm_none_eabi',
            label: 'rhe8 && x86_64 && docker',
            params: '--target=arm-none-eabi --aprofile -- --host=x86_64-none-linux-gnu --release --package --enable-newlib-nano --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ],
        // linux targetx
        [
            id: 'H:aarch64_none_linux_gnu T:aarch64_none_linux_gnu',
            label: 'aarch64 && docker',
            params: '--target=aarch64-none-linux-gnu -- --host=aarch64-none-linux-gnu --config-flags-libc="--enable-crypt" --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:aarch64_none_linux_gnu',
            label: 'rhe8 && x86_64 && docker',
            params: '--target=aarch64-none-linux-gnu -- --host=x86_64-none-linux-gnu --config-flags-libc="--enable-crypt" --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ],
        [
            id: 'H:aarch64_none_linux_gnu T:arm_none_linux_gnueabihf',
            label: 'aarch64 && docker',
            params: '--target=arm-none-linux-gnueabihf -- --host=aarch64-none-linux-gnu --config-flags-libc="--enable-crypt" --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:arm_none_linux_gnueabihf',
            label: 'rhe8 && x86_64 && docker',
            params: '--target=arm-none-linux-gnueabihf -- --host=x86_64-none-linux-gnu --config-flags-libc="--enable-crypt"  --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ],
        // MAC
        /*
         * MacOS builds disabled because of the failure caused by autoreconf.
         * Once a proper solution is introduced to run autoconf, we will run the builds on mac too.
         * See: https://jira.arm.com/browse/GNUTOOLS-14690
        [
            id: 'H:arm64_apple_darwin T:aarch64_none_elf',
            label: 'Darwin && arm64',
            params: '--target=aarch64-none-elf -- --host=arm64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ],
        [
            id: 'H:x86_64_apple_darwin T:aarch64_none_elf',
            label: 'Darwin && macpro && x86_64',
            params: '--target=aarch64-none-elf -- --host=x86_64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ],
        [
            id: 'H:arm64_apple_darwin T:arm_none_eabi',
            label: 'Darwin && arm64',
            params: '--target=arm-none-eabi -- --host=arm64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ],
        [
            id: 'H:x86_64_apple_darwin T:arm_none_eabi',
            label: 'Darwin && macpro && x86_64',
            params: '--target=arm-none-eabi -- --host=x86_64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ]
        */
    ]

def doBuild(jobSpecs) {
    stage('Checkout') {
        checkout scm
    }
    stage('build') {
        sshagent(credentials: ['dgboter-ssh']) {
            sh """\
                mkdir src
                ln -s $WORKSPACE src/gnu-devtools-for-arm
                wget $TOOLCHAIN_TARBALL_URL -O arm-gnu-toolchain-src-snapshot.tar.xz
                tar -xf arm-gnu-toolchain-src-snapshot.tar.xz -C $WORKSPACE/src
            """
            runAutoConf(["$WORKSPACE/src/isl", "$WORKSPACE/src/libexpat/expat"])
            sh"""
                export PATH="${WORKSPACE}/${GNU_TOOLS_PATH}:$PATH"
                build-gnu-toolchain.sh ${jobSpecs.params} --builddir=$WORKSPACE/build
            """
        }
    }
}


def buildInContainer(jobSpecs) {
    stage("Run container") {
        def uid = sh(script: 'id -u', returnStdout: true).trim()
        def gid = sh(script: 'id -g', returnStdout: true).trim()
        sh """
            cp /etc/{group,passwd} $WORKSPACE
            getent passwd ${localUser} >> passwd
            getent group ${localUser} >> group
        """
        docker.withRegistry("https://${afGnuRegistry}/", 'gnuci-af-api-key') {
            docker.image("${afGnuRegistry}/${dockerImgName}:latest").inside("--platform ${jobSpecs.cplatform} -v $WORKSPACE/passwd:/etc/passwd:ro -v $WORKSPACE/group:/etc/group:ro -v /home/${localUser}:/home/${localUser} -u ${uid}:${gid} -e HOME=/home/${localUser}") {
                // Build inside container
                doBuild(jobSpecs)
            }
        }
    }
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

def generateStage(jobSpecs) {
    def stageVenv = "${params.BLD_PYTHON_ENV_PATH}"
    return {
        stage(jobSpecs.id) {
            node ("${jobSpecs.label}") {
                stage ("Clean up"){
                    cleanWs()
                }
                // Build in container if cplatform is defined
                if (jobSpecs.cplatform != "") {
                    buildInContainer(jobSpecs)
                } else {
                    doBuild(jobSpecs)
                }
            }
        }
    }
}


def devtoolsBuildMap = devtools.collectEntries {
    ["${it}" : generateStage(it)]
}


pipeline {
    environment {
        def afGnuRegistry = 'dsg-gnu--docker.artifactory.geo.arm.com'
        def dockerImgName = 'build/ubu2204gnudevtools'
        def localUser = 'dgboter'
        def GNU_TOOLS_PATH = "src/gnu-devtools-for-arm"  // Relative path to gnu-devtools in the workspace
        TOOLCHAIN_TARBALL_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/srcrel/arm-gnu-toolchain-src-snapshot-13.2.rel1.tar.xz"
    }
    options {
        // This is required so that we first clean the workspace and then we do the scm checkout
        skipDefaultCheckout(true)
    }
    agent { label 'aarch64' }
    stages {
        stage('Run all builds') {
            steps {
                script {
                    // Generated parallel stages for builds
                    parallel devtoolsBuildMap
                }
            }
        }
    }
}
