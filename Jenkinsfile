//@Library('timhaus-automation') _

pipeline {
  triggers {
    cron('H 5 * * 0')
  }
  options {
    ansiColor('xterm')
  }
  agent none

  stages {
      // stage('Prep Runtime Env') {
      //     steps {
      //         setRunEnv()
      //     }
      // }
      
    stage('Container upgrades') {
      parallel {
        stage('Upgrade Vox') {
          agent { label  'vox' }
          steps {
            withCredentials([usernamePassword(credentialsId: 'jenkins-user-auth', passwordVariable: 'pass', usernameVariable: 'username')]) {
              sh('ruby ./docker-compose/update_docker_container.rb vox $pass')
            }
          }
        }
        stage('Upgrade Founder') {
          agent { label 'founder' }
          steps {
            withCredentials([usernamePassword(credentialsId: 'jenkins-user-auth', passwordVariable: 'pass', usernameVariable: 'username')]) {
              sh('ruby ./docker-compose/update_docker_container.rb founder $pass')
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
