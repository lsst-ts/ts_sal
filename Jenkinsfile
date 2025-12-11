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
    buildDiscarder(
        logRotator (
            artifactDaysToKeepStr: '',
            artifactNumToKeepStr: '',
            daysToKeepStr: '14',
            numToKeepStr: '10'
		)
	),
    disableConcurrentBuilds()
    ]
)
pipeline {
    agent {
        docker {
            image 'lsstts/salobj:develop'
            alwaysPull true
            args "--entrypoint=''"
        }
    }
    environment {
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
                checkout poll: false, scm: [$class: 'GitSCM', branches: [[name: 'develop']], extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'simple_sal']], userRemoteConfigs: [[credentialsId: '2f201490-cd26-46b6-9fd3-193560c72140', url: 'https://github.com/lsst-camera-ccs/org-lsst-camera-simple-sal.git']]]     
            }
        }
        stage("Build SAL runtime assets") {
            steps {
                script {
                    sh """ cd ${env.WORKSPACE}
                    source ~/.setup.sh
                    export HOME=${env.WORKSPACE}
                    
                    # Configure environment variables
                    export LSST_SDK_INSTALL=${env.WORKSPACE}
                    export LSST_SAL_PREFIX=\$CONDA_PREFIX
                    export TS_XML_DIR=/home/saluser/repos/ts_xml
                    # TBD: Should the topic be test as apposed to sal
                    # to avoid conflicts with production?
                    #export LSST_TOPIC_SUBNAME=test
                    export LSST_TOPIC_SUBNAME=sal

                    # Run the new setup script (builds dependencies, libserdes, etc.)
                    ./bin/setup_stack_build.sh
                    
                    # Source the complete SAL environment
                    source ./bin/salenv_complete.sh
                    
                    cd ${env.WORKSPACE}/test
                    
                    # Generate SAL runtime for Test and Script components
                    for COMPONENT in Test Script; do
                        salgeneratorKafka validate "\$COMPONENT"
                        salgeneratorKafka sal cpp "\$COMPONENT"
                        salgeneratorKafka sal java "\$COMPONENT"
                        salgeneratorKafka lib "\$COMPONENT"
                        salgeneratorKafka maven "\$COMPONENT"
                    done
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
                    export LSST_SAL_PREFIX=\$CONDA_PREFIX
                    export TS_XML_DIR=/home/saluser/repos/ts_xml
                    # TBD: Should the topic be test as apposed to sal
                    # to avoid conflicts with production?
                    #export LSST_TOPIC_SUBNAME=test
                    export LSST_TOPIC_SUBNAME=sal
                    
                    # Source the complete SAL environment
                    source ./bin/salenv_complete.sh

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
                    export LSST_SAL_PREFIX=\$CONDA_PREFIX
                    export TS_XML_DIR=/home/saluser/repos/ts_xml
                    # TBD: Should the topic be test as apposed to sal
                    # to avoid conflicts with production?
                    #export LSST_TOPIC_SUBNAME=test
                    export LSST_TOPIC_SUBNAME=sal
                    
                    # Source the complete SAL environment
                    source ./bin/salenv_complete.sh
                    
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
            cd ${env.WORKSPACE}/doc
            sphinx-build -b html . _build/html
            echo "Documentation built successfully in doc/_build/html"
            cd ${env.WORKSPACE}
            
            # Install uv if not present (for ltd-conveyor Python 3.11 compatibility)
            if ! command -v uvx >/dev/null 2>&1; then
                echo "Installing uv for documentation upload..."
                pip install --quiet uv
            fi
            
            # Upload documentation to LSST the Docs
            # IMPORTANT: We use uvx with Python 3.11 because:
            #   - TSSW Jenkins uses old ltd-conveyor version (0.8.x)
            #   - ltd-conveyor 0.8.x has compatibility issues with Python 3.13
            #   - Python 3.11 environment (before setuptools dropped pkg_resources) is more stable
            #   - uvx creates isolated Python 3.11 environment just for this command
            # Note: Credentials MUST be quoted to handle special characters in password
            LTD_USERNAME="${LSST_IO_CREDS_USR}" LTD_PASSWORD="${LSST_IO_CREDS_PSW}" \
              uvx --python 3.11 --from 'ltd-conveyor>0.8,<0.9' ltd upload --product ts-sal --git-ref ${GIT_BRANCH} --dir doc/_build/html || echo "Upload failed... ignoring."
            """
            }
        cleanup {
            deleteDir()
        }
    }
}
