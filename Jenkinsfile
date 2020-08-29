pipeline {
    agent {
        docker {
            image "barichello/godot-ci:3.2.1"
            args '-u root --privileged'
        }
    }
    environment {
      EXPORT_NAME = "lowrez_game"
    }
    stages {
        stage('Build Windows') {
            steps {
              echo 'Building for Windows'
              sh "mkdir ${EXPORT_NAME}_windows"
              sh "godot  -v --export 'Windows Desktop' ./${EXPORT_NAME}_windows/${EXPORT_NAME}.exe"
              sh "zip -r ${EXPORT_NAME}_windows.zip ${EXPORT_NAME}_windows"
              archiveArtifacts artifacts: '*.zip', fingerprint: true
            }
        }
        stage('Build Linux') {
            steps {
              echo 'Building for Linux'
              sh "mkdir ${EXPORT_NAME}_linux"
              sh "godot -v --export Linux/X11 ./${EXPORT_NAME}_linux/${EXPORT_NAME}.x86_64"
              sh "tar -zcvf ${EXPORT_NAME}_linux.tar.gz ${EXPORT_NAME}_linux"
              archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
            }
        }
        stage('Build MacOS') {
            steps {
              echo 'Building for MacOS'
              sh "godot -v --export 'Mac OSX' ./${EXPORT_NAME}_macos.zip"
              archiveArtifacts artifacts: '*.zip', fingerprint: true
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
