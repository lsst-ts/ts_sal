pipeline {
    agent any
    environment {
        dockerImageNameBuild = "salobj:b${BUILD_NUMBER}"
        dockerImageBuild = ""
        work_branches = "${GIT_BRANCH} ${CHANGE_BRANCH} master"
        container_name = "c_${BUILD_ID}_${JENKINS_NODE_COOKIE}"
        network_name = "n_${BUILD_ID}_${JENKINS_NODE_COOKIE}"
    }

    stages {
        stage("Create docker network.") {
            steps {
                script {
                    sh """
                    printenv
                    docker network ls
                    docker network create ${network_name}
                    """
                }
            }

        }
        stage("Build") {
            steps {
                script {
                    dockerImageBuild = docker.build(dockerImageNameBuild, "--no-cache --network ${network_name} --build-arg sal_v=\"${work_branches}\" --build-arg xml_v=\"${work_branches}\" --build-arg base_image_tag=master .")
                }
            }
        }
        stage("Copy tests results") {
            steps {
                script {
                    sh """
                    docker run --name ${container_name} -dit --rm ${dockerImageNameBuild}
                    mkdir -p jenkinsReport
                    docker cp ${container_name}:/home/saluser/repos/ts_sal/tests/.tests/pytest-ts_sal.xml jenkinsReport/
                    docker cp ${container_name}:/home/saluser/repos/ts_sal/tests/.tests/pytest-ts_sal.xml-cov-ts_sal.xml jenkinsReport/
                    docker cp ${container_name}:/home/saluser/repos/ts_sal/tests/.tests/pytest-ts_sal.xml-htmlcov htmlcov
                    """
                }
            }
        }
    }
    post {
        always {
            // The path of xml needed by JUnit is relative to
            // the workspace.
            junit 'jenkinsReport/*.xml'

            // Publish the HTML report
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'htmlcov',
                reportFiles: 'index.html',
                reportName: "Coverage Report"
              ])
        }
        cleanup {
            sh """
            docker stop ${container_name}
            docker network rm ${network_name}
            """
        }
    }
}
