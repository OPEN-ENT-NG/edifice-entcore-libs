#!/usr/bin/env groovy

pipeline {
  agent any

  stages {
    stage("Initialization") {
      when {
        environment name: 'RENAME_BUILDS', value: 'true'
      }
      steps {
        script {
          sh './build.sh $BUILD_SH_EXTRA_PARAM init'
          def version = sh(returnStdout: true, script: 'docker run -it --rm -u 1000:1000 --env MAVEN_CONFIG=/var/maven/.m2 -w /usr/src/maven -v ./:/usr/src/maven -v ~/.m2:/var/maven/.m2  opendigitaleducation/mvn-java8-node20:latest mvn -Duser.home=/var/maven help:evaluate -Dexpression=project.version -DforceStdout -q')
          buildName "${env.GIT_BRANCH.replace("origin/", "")}@${version}"
        }
      }
    }
    stage('Build') {
      steps {
        checkout scm
        sh './build.sh $BUILD_SH_EXTRA_PARAM init clean install'
      }
    }
    stage('Test') {
      steps {
        script {
          sh 'sleep 6'
/*            try {
            sh './build.sh $BUILD_SH_EXTRA_PARAM test'
          } catch (err) {
          }*/
        }
      }
    }
    stage('Publish') {
      steps {
        sh "DRY_RUN=false ./build.sh \$BUILD_SH_EXTRA_PARAM publish"
      }
    }

    stage('Build image') {
          steps {
              sh 'edifice image'
        }
    }
  }
  post {
    cleanup {
      sh 'docker compose down'
    }
  }
}

