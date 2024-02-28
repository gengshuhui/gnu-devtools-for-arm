*** Settings ***
Library    OperatingSystem

*** Variables ***
${gcc}     ${builddir}/install/bin/${target}-gcc

*** Test Cases ***
${jobId} gcc is executable
    Log    Check if gcc runs correctly on x86_64
    ${rc} =    Run and Return RC    ${gcc} --version
    Should Be Equal As Integers    ${rc}    0
    Log    ${rc}

${jobId} gcc version contains bld tag
    Log    Check gcc version has arm-11.32
    ${output} =    Run    ${gcc} --version
    Should Contain    ${output}    ${release}
    Log    ${output}
