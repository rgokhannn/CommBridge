pipeline {
    agent any

    stages {
    //    stage('Initialize Setup') {
    //        steps {
    //             script {
    //                 try {
    //                     sh 'chmod +x initialSetup.sh'
    //                     sh 'sudo ./initialSetup.sh'
    //                 } catch (Exception e) {
    //                     error "Initialization failed: ${e.message}"
    //                 }
    //             }
    //         }
    //     }

        stage('Generate Credentials') {
            steps {
                script {
                    try {
                        sh 'chmod +x generateCredentials.sh'
                        sh './generateCredentials.sh'
                    } catch (Exception e) {
                        error "Credentials generation failed: ${e.message}"
                    }
                }
            }
        }

        stage('Build and Deploy') {
            steps {
                script {
                    try {
                        sh 'docker-compose up --build -d'
                    } catch (Exception e) {
                        error "Build and deploy failed: ${e.message}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'

            // Artifacts for archiving
            archiveArtifacts artifacts: '**/logs/*.log', allowEmptyArchive: true
        }
        failure {
            echo 'Pipeline has failed. Please check the logs for more details.'
        }
        success {
            echo 'Pipeline executed successfully.'
        }
    }
}