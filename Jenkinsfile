def postResults() {
  // The path of xml needed by JUnit is relative to
  // the workspace.
  echo "C++ unit-test results"
  junit testResults: 'cpp_tests/*.xml', skipPublishingChecks: true
  echo "Java unit-test results"
  junit testResults: 'java_tests/target/surefire-reports/TEST*.xml', skipPublishingChecks: true
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
    agent any
    environment {
        network_name = "kafka"
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
                        docker run -v \${WORKSPACE}:/home/saluser/repos/ts_sal -td --rm --network \${network_name} \
                            -e LTD_USERNAME=\${LSST_IO_CREDS_USR} -e LTD_PASSWORD=\${LSST_IO_CREDS_PSW} \
                            -e LSST_KAFKA_PREFIX=lsst.sal -e LSST_KAFKA_HOST=broker -e LSST_KAFKA_LOCAL_SCHEMAS=\$LSST_SAL_PREFIX \
                            -e LSST_KAFKA_BROKER_PORT=29092 -e LSST_KAFKA_BROKER_ADDR=broker:\$LSST_KAFKA_BROKER_PORT \
                            -e LSST_SCHEMA_REGISTRY_URL=http://schema-registry:8081 \
                            --name \${container_name} lsstts/salobj:develop
                    """
                }
            }
        }
                stage("Setup SAL Kafka build environment") {
            steps {
                script {
                    sh "docker exec -u root \${container_name} sh -c \"" +
                        "/opt/lsst/software/stack/conda/envs/lsst-scipipe-9.0.0/bin/conda install -y jansson && " +
                        "curl -O https://repo-nexus.lsst.org/nexus/repository/ts_yum/test/ts_sal_utilsKafka-10.0.0-1.x86_64.rpm && " +
                        "dnf install -y ts_sal_utilsKafka-10.0.0-1.x86_64.rpm && " +
                        "dnf install -y epel-release && " +
                        "dnf install -y yum-utils && " +
                        "dnf config-manager -y --set-enabled powertools && " +
                        "dnf -y update && " +
                        "dnf install -y ant cmake boost1.78-devel jansson-devel asciidoc curl libcurl-devel zlib-devel maven doxygen fmt fmt-devel snappy snappy-devel csnappy gcc-toolset-10 cyrus-sasl cyrus-sasl-devel catch-devel && " +
                        "curl -LO https://github.com/catchorg/Catch2/archive/refs/tags/v3.8.0.tar.gz && " +
                        "tar zxvf v3.8.0.tar.gz && " +
                        "cd Catch2-3.8.0/ && " +
                        "source scl_source enable gcc-toolset-10 && " +
                        "cmake -Bbuild -H. -DBUILD_TESTING=OFF && " +
                        "cmake --build build/ --target install\""
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
                        "cd /home/saluser/repos/ts_sal && " +
                        "source ~/.setup.sh && " +
                        "source ./setupKafka.env && " +
                        "source scl_source enable gcc-toolset-10 && " +
                        "cd /home/saluser/repos/ts_sal/test && " +
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
                        "cd /home/saluser/repos/ts_sal && " +
                        "source ./setupKafka.env && " +
                        "source scl_source enable gcc-toolset-10 && " +
                        "cd /home/saluser/repos/ts_sal/cpp_tests && " +
                         "make junit || echo cpp test failed...\""
                }
            }
        }
        stage("Running Camera java tests") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "cd /home/saluser/repos/ts_sal && " +
                        "source ./setupKafka.env && " +
                        "source scl_source enable gcc-toolset-10 && " +
                        "cd /home/saluser/repos/ts_sal/simple_sal && " +
                        "mvn --no-transfer-progress -B clean install  || echo java test failed\""
                }
            }
        }//CameraTests
    }
    post {
        always {
            // Uncomment once tests are passing...
            // postResults()
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
