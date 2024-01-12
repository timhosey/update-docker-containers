//@Library('timhaus-automation') _

pipeline {
    triggers {
      cron('H 5 * * 0')
    }
    options {
      ansiColor('xterm')
    }

    stages {
        // stage('Prep Runtime Env') {
        //     steps {
        //         setRunEnv()
        //     }
        // }
        
        stage('Container upgrades') {
          parallel {
            stage('Upgrade Vox') {
              steps {
                withCredentials([usernamePassword(credentialsId: 'jenkins-user-auth', passwordVariable: 'pass', usernameVariable: 'username')]) {
                  sh "ruby ./docker-compose/update_docker_container.rb vox $pass"
                }
              }
            }
            stage('Upgrade Founder') {
              steps {
                withCredentials([usernamePassword(credentialsId: 'jenkins-user-auth', passwordVariable: 'pass', usernameVariable: 'username')]) {
                  sh "ruby ./docker-compose/update_docker_container.rb founder $pass"
                }
              }
            }
            // TODO: Add Dewitt and Comstock
          }
          post {
            always {
              echo 'Process completed!'
            }
          }
          
        }
    }
}
