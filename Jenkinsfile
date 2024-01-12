@Library('timhaus-automation') _

pipeline {
    agent { label "${AGENT}" }
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
        
        stage('Run Ruby') {
            steps {
              withCredentials([usernamePassword(credentialsId: 'jenkins-user-auth', passwordVariable: 'pass', usernameVariable: 'username')]) {
                sh "ruby ./docker-compose/update_docker_container.rb $AGENT $pass"
              }
            }
        }
    }
}
