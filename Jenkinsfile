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
    agent any
    environment {
        network_name = "n_${BUILD_ID}_${JENKINS_NODE_COOKIE}"
        container_name = "c_${BUILD_ID}_${JENKINS_NODE_COOKIE}"
        work_branches = "${GIT_BRANCH} ${CHANGE_BRANCH} develop"
        LSST_IO_CREDS = credentials("lsst-io")
        SQUASH_CREDS = credentials("squash")
    }

    stages {
        stage("Pulling docker image") {
            steps {
                script {
                    sh "docker pull lsstts/salobj:develop"
                }
            }
        }
        stage("Preparing environment") {
            steps {
                script {
                    sh """
                    docker network create \${network_name}
                    container=\$(docker run -v \${WORKSPACE}:/home/saluser/repos/ts_sal -td --rm --net \${network_name} -e LTD_USERNAME=\${LSST_IO_CREDS_USR} -e LTD_PASSWORD=\${LSST_IO_CREDS_PSW} --name \${container_name} lsstts/salobj:develop)
                    """
                }
            }
        }
        stage("Checkout xml") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "cd /home/saluser/repos/ts_xml && " +
                        "/home/saluser/.checkout_repo.sh \${work_branches} && " +
                        "git pull\""
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
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "mamba install -y catch2 && " +
                        "source ~/.setup.sh && " +
                        "cd /home/saluser/repos/ts_sal/cpp_tests && " +
                        "salgeneratorKafka validate Test && " +
                        "salgeneratorKafka validate Script && " +
                        "salgeneratorKafka sal cpp Test && " +
                        "salgeneratorKafka sal cpp Script && " +
                        "salgeneratorKafka sal java Test && " +
                        "salgeneratorKafka sal java Script && " +
                        "salgeneratorKafka lib Test && " +
                        "salgeneratorKafka lib Script && " +
                        "salgeneratorKafka maven Test && " +
                        "salgeneratorKafka maven Script\""
                }
            }
        }
        stage("Running cpp tests") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "mamba install -y catch2 && " +
                        "cd /home/saluser/repos/ts_sal/cpp_tests && " +
                         "make junit\""
                }
            }
        }
        stage("Running Camera java tests") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "cd /home/saluser/repos/ts_sal/simple_sal && " +
                        "mvn --no-transfer-progress -B clean install \""
                    
                }
            }
        }//CameraTests
    }
    post {
        always {
            // The path of xml needed by JUnit is relative to
            // the workspace.
            echo "C++ unit-test results"
            junit testResults: 'cpp_tests/*.xml', skipPublishingChecks: true
            echo "Java unit-test results"
            junit testResults: 'java_tests/target/surefire-reports/TEST*.xml', skipPublishingChecks: true
            echo "Java unit-test results"
            junit testResults: 'simple_sal/**/target/surefire-reports/TEST*.xml', skipPublishingChecks: true

            echo "Build documents"
            sh "docker exec -u saluser \${container_name} sh -c \"" +
                "source ~/.setup.sh && " +
                "cd /home/saluser/repos/ts_sal && " +
                "setup ts_sal -t saluser && " +
                "package-docs build\""

            echo "Publish documents"
            script {
                def RESULT = sh returnStatus: true, script: "docker exec -u saluser \${container_name} sh -c \"" +
                    "source ~/.setup.sh && " +
                    "cd /home/saluser/repos/ts_sal && " +
                    "setup ts_sal -t saluser && " +
                    "ltd upload --product ts-sal --git-ref \${GIT_BRANCH} --dir doc/_build/html\""

                if ( RESULT != 0 ) {
                    unstable("Failed to push documentation.")
                }
            }
        }
        cleanup {
            sh """
                docker stop \${container_name} || echo Could not stop container
                docker network rm \${network_name} || echo Could not remove network
            """
            deleteDir()
        }
    }
}
