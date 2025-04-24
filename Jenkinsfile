def postResults() {
  // The path of xml needed by JUnit is relative to
  // the workspace.
  echo "C++ unit-test results"
  junit testResults: 'cpp_tests/*.xml', skipPublishingChecks: true
  echo "Java unit-test results"
  junit testResults: 'simple_sal/**/target/surefire-reports/TEST*.xml', skipPublishingChecks: true
}

properties(
    [
    buildDiscarder
        (logRotator (
            artifactDaysToKeepStr: '',
            artifactNumToKeepStr: '',
            daysToKeepStr: '14',
            numToKeepStr: '10'
        ) ),
    disableConcurrentBuilds()
    ]
)
pipeline {
    agent {
        docker {
            image 'lsstts/salobj:develop'
            alwaysPull true
            args "--entrypoint='' --network=kafka"
        }
    }
    environment {
        network_name = "kafka"
        container_name = "c_${BUILD_ID}_${JENKINS_NODE_COOKIE}"
        work_branches = "${GIT_BRANCH} ${CHANGE_BRANCH} develop"
        LSST_IO_CREDS = credentials("lsst-io")
        SQUASH_CREDS = credentials("squash")
    }

    stages {
        stage("Checkout xml") {
            steps {
                script {
                    sh """
                    source ~/.setup.sh
                    cd /home/saluser/repos/ts_xml
                    /home/saluser/.checkout_repo.sh ${WORK_BRANCHES}
                    """
                }
            }
        }
        stage('Checkout simple-sal') {
            steps {
                checkout poll: false, scm: [$class: 'GitSCM', branches: [[name: 'develop']], extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'simple_sal']], userRemoteConfigs: [[credentialsId: '14e4c262-1fb1-4b73-b395-5fe617420c85', url: 'https://github.com/lsst-camera-ccs/org-lsst-camera-simple-sal.git']]]     
            }
        }
        stage("Build SAL runtime assets") {
            steps {
                script {
                    sh """ cd ${env.WORKSPACE}
                    source ~/.setup.sh
                    export HOME=${env.WORKSPACE}
                    ./bin/setupStackBuildEnvironment
                    export LSST_SDK_INSTALL=${env.WORKSPACE}
                    source ./setupKafka.env
                    export TS_XML_DIR=/home/saluser/repos/ts_xml
                    cd ${env.WORKSPACE}/test
                    salgeneratorKafka validate Test
                    salgeneratorKafka validate Script
                    salgeneratorKafka sal cpp Test
                    salgeneratorKafka sal cpp Script
                    salgeneratorKafka sal java Test
                    salgeneratorKafka sal java Script
                    salgeneratorKafka lib Test
                    salgeneratorKafka lib Script
                    salgeneratorKafka maven Test
                    salgeneratorKafka maven Script
                    """
                }
            }
        }
        stage("Running cpp tests") {
            steps {
                script {
                    sh """source ~/.setup.sh
                    cd ${env.WORKSPACE}
                    export LSST_SDK_INSTALL=${env.WORKSPACE}
                    source ./setupKafka.env
                    export TS_XML_DIR=/home/saluser/repos/ts_xml
                    export BOOST_RELEASE=
                    export LSST_KAFKA_PRODUCER_WAIT_ACKS=1
                    cd ${env.WORKSPACE}/cpp_tests
                    make junit
                    """
                }
            }
        }
        stage("Running Camera java tests") {
            steps {
                script {
                    sh """source ~/.setup.sh
                    cd ${env.WORKSPACE}
                    export LSST_SDK_INSTALL=${env.WORKSPACE}
                    source ./setupKafka.env
                    export TS_XML_DIR=/home/saluser/repos/ts_xml
                    cd ${env.WORKSPACE}/simple_sal
                    mvn --no-transfer-progress -B clean install
                    """
                }
            }
        }//CameraTests
    }
    post {
        always {
            // Uncomment once tests are passing...
            // postResults()
            echo "Build documents"
            sh """ source ~/.setup.sh
            cd ${env.WORKSPACE}
            setup -kr .
            package-docs build
            ltd upload --product ts-sal --git-ref ${GIT_BRANCH} --dir doc/_build/html || echo "Upload failed... ignoring."
            """
            }
        cleanup {
            deleteDir()
        }
    }
}
