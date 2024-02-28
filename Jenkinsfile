
// cplatforms: linux/arm64, linux/arm/v7, linux/amd64

stashes = []

def devtools =
[
    buildBaremetal: [
        // baremetal targets
        [
            id: 'H:aarch64_none_linux_gnu T:aarch64_none_elf',
            label: 'aarch64 && docker',
            target: 'aarch64-none-elf',
            params: '--target=aarch64-none-elf -- --host=aarch64-none-linux-gnu --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:aarch64_none_elf',
            label: 'rhe8 && x86_64 && docker',
            target: 'aarch64-none-elf',
            params: '--target=aarch64-none-elf -- --host=x86_64-none-linux-gnu --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ],
        [
            id: 'H:aarch64_none_linux_gnu T:arm_none_eabi',
            label: 'aarch64 && docker',
            target: 'arm-none-eabi',
            params: '--target=arm-none-eabi --aprofile -- --host=aarch64-none-linux-gnu --release --package --enable-newlib-nano --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:arm_none_eabi',
            label: 'rhe8 && x86_64 && docker',
            target: 'arm-none-eabi',
            params: '--target=arm-none-eabi --aprofile -- --host=x86_64-none-linux-gnu --release --package --enable-newlib-nano --enable-gdb-with-python=yes',
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
            target: 'aarch64-none-elf',
            params: '--target=aarch64-none-elf -- --host=arm64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ],
        [
            id: 'H:x86_64_apple_darwin T:aarch64_none_elf',
            label: 'Darwin && macpro && x86_64',
            target: 'aarch64-none-elf',
            params: '--target=aarch64-none-elf -- --host=x86_64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ],
        [
            id: 'H:arm64_apple_darwin T:arm_none_eabi',
            label: 'Darwin && arm64',
            target: 'arm-none-eabi',
            params: '--target=arm-none-eabi -- --host=arm64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ],
        [
            id: 'H:x86_64_apple_darwin T:arm_none_eabi',
            label: 'Darwin && macpro && x86_64',
            target: 'arm-none-eabi',
            params: '--target=arm-none-eabi -- --host=x86_64-apple-darwin --release --package --enable-gdb-with-python=no',
            cplatform: ''
        ]
        */
    ],
    buildCrossLinux: [
        // linux target
        [
            id: 'H:aarch64_none_linux_gnu T:aarch64_none_linux_gnu',
            label: 'aarch64 && docker',
            target: 'aarch64-none-linux-gnu',
            params: '--target=aarch64-none-linux-gnu -- --host=aarch64-none-linux-gnu --config-flags-libc="--enable-crypt" --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:aarch64_none_linux_gnu',
            label: 'rhe8 && x86_64 && docker',
            target: 'aarch64-none-linux-gnu',
            params: '--target=aarch64-none-linux-gnu -- --host=x86_64-none-linux-gnu --config-flags-libc="--enable-crypt" --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ],
        [
            id: 'H:aarch64_none_linux_gnu T:arm_none_linux_gnueabihf',
            label: 'aarch64 && docker',
            target: 'arm-none-linux-gnueabihf',
            params: '--target=arm-none-linux-gnueabihf -- --host=aarch64-none-linux-gnu --config-flags-libc="--enable-crypt" --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/arm64'
        ],
        [
            id: 'H:x86_64_none_linux_gnu T:arm_none_linux_gnueabihf',
            label: 'rhe8 && x86_64 && docker',
            target: 'arm-none-linux-gnueabihf',
            params: '--target=arm-none-linux-gnueabihf -- --host=x86_64-none-linux-gnu --config-flags-libc="--enable-crypt"  --release --package --enable-gdb-with-python=yes',
            cplatform: 'linux/amd64'
        ]
    ]
]

def doBuild(jobSpecs) {
    stage('Checkout') {
        checkout scm
    }
    stage('build') {
        try {
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
        } catch (err) {
            echo "Caught a build error: ${err}"
            error("Build Failed: ${jobSpecs.id}")
        }
    }
    stage('Out Of Box Testing') {
        sshagent(credentials: ['dgboter-ssh']) {
            def jobId = "${jobSpecs.id}".replaceAll("\\s","").replaceAll(":","-")
            sh """\
                /usr/bin/python3 -m venv "${WORKSPACE}/venv3"
                . "${WORKSPACE}/venv3/bin/activate"
                pip install robotframework
                robot --legacy-output --variable jobId:${jobId} --variable builddir:${WORKSPACE}/build --variable release:${release} --variable target:${jobSpecs.target} --outputDir reports/${jobId} --consolecolors on --removekeywords tag:sensitive tests/*.robot
            """
            stash name: "${jobId}", includes: "reports/${jobId}/**"
            stashes.push("${jobId}")
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

def buildDevtoolsMap(devtools) {
    def devtoolsBuildMap = [:]
    buildScriptTargets.each {
        buildScript ->
        def targets = devtools["${buildScript}"]
        devtoolsBuildMap += targets.collectEntries {
            ["${it}" : generateStage(it)]
        }
    }
    return devtoolsBuildMap
}

def selectBuildScriptTargets() {
    buildScriptTargets = []
    def scmVars = checkout scm
    def gitFilesDiff = sh(script: "git diff-tree --no-commit-id --name-only -r ${scmVars.GIT_COMMIT}", returnStdout: true).trim().split('\n')
    println "Changed files: ${gitFilesDiff}"
    gitFilesDiff.each {
        file ->
        if ("${file}" ==~ /build-baremetal-toolchain.sh/) {
            if (!buildScriptTargets.contains("buildBaremetal")) {
                buildScriptTargets.push("buildBaremetal");
            }
        } else if ("${file}" ==~ /build-cross-linux-toolchain.sh/) {
            if (!buildScriptTargets.contains("buildCrossLinux")) {
                buildScriptTargets.push("buildCrossLinux");
            }
        } else if ("${file}" ==~ /build-gnu-toolchain.sh/ || "${file}" ==~ /utilities.sh/) {
            if (!buildScriptTargets.contains("buildBaremetal")) {
                buildScriptTargets.push("buildBaremetal");
            }
            if (!buildScriptTargets.contains("buildCrossLinux")) {
                buildScriptTargets.push("buildCrossLinux");
            }
        }
    }
    println "Build targets: ${buildScriptTargets}"
}

pipeline {
    environment {
        def afGnuRegistry = 'dsg-gnu--docker.artifactory.geo.arm.com'
        def dockerImgName = 'build/ubu2204gnudevtools'
        def localUser = 'dgboter'
        def release = "13.2.Rel1"
        def GNU_TOOLS_PATH = "src/gnu-devtools-for-arm"  // Relative path to gnu-devtools in the workspace
        TOOLCHAIN_TARBALL_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/srcrel/arm-gnu-toolchain-src-snapshot-13.2.rel1.tar.xz"
    }
    options {
        // This is required so that we first clean the workspace and then we do the scm checkout
        skipDefaultCheckout(true)
    }
    agent { label 'aarch64' }
    stages {
        stage('Check deltas') {
            steps {
                script {
                    cleanWs()
                    selectBuildScriptTargets()
                }
            }
        }

        stage('Run all builds') {
            when { expression { !buildScriptTargets.isEmpty() } }
            steps {
                script {
                    // Generated parallel stages for builds
                    parallel buildDevtoolsMap(devtools)
                }
            }
        }
    }
    post {
        always {
            script {
                if(stashes) {
                    stashes.each {
                        stashName ->
                        unstash stashName
                    }
                    robot archiveDirName: 'robot-plugin', outputPath: 'reports', outputFileName: "**/output.xml", reportFileName: '**/report.html', logFileName: '**/log.html', passThreshold: 100.0, unstableThreshold: 90.0
                }
            }
        }
    }
}
