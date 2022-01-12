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
                    chmod -R a+rw \${WORKSPACE}
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
        stage("Checkout IDL") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "source /home/saluser/.bashrc && " +
                        "cd /home/saluser/repos/ts_idl && " +
                        "/home/saluser/.checkout_repo.sh \${work_branches} && " +
                        "git pull\""
                }
            }
        }
        stage("Running tests") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "export LSST_DDS_QOS=file:///home/saluser/repos/ts_ddsconfig/qos/QoS.xml && " +
                        "cd /home/saluser/repos/ts_sal && " +
                        "make_salpy_libs.py Test Script && " +
                        "pytest --junitxml=tests/.tests/junit.xml\""
                }
            }
        }
        stage("Running cpp tests") {
            steps {
                script {
                    sh "docker exec -u saluser \${container_name} sh -c \"" +
                        "source ~/.setup.sh && " +
                        "conda install -y catch2 && " +
                        "export LSST_DDS_QOS=file:///home/saluser/repos/ts_ddsconfig/qos/QoS.xml && " +
                        "cd /home/saluser/repos/ts_sal/cpp_tests && " +
                        "salgenerator generate cpp Test && " +
                        "salgenerator generate cpp Script && " +
                        "export LSST_DDS_PARTITION_PREFIX=test && " +
                        "make junit\""
                }
            }
        }
    }
    post {
        always {
            // The path of xml needed by JUnit is relative to
            // the workspace.
            junit 'tests/.tests/junit.xml'
            junit 'cpp_tests/*.xml'

            // Publish the HTML report
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'tests/.tests/',
                reportFiles: 'index.html',
                reportName: "Coverage Report"
              ])
              sh "docker exec -u saluser \${container_name} sh -c \"" +
                  "source ~/.setup.sh && " +
                  "cd /home/saluser/repos/ts_sal && " +
                  "setup ts_sal -t saluser && " +
                  "package-docs build\""

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
                docker exec -u root --privileged \${container_name} sh -c \"chmod -R a+rw /home/saluser/repos/ts_sal/\"
                docker stop \${container_name} || echo Could not stop container
                docker network rm \${network_name} || echo Could not remove network
            """
            deleteDir()
        }
    }
}
