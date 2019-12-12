def VERSION = 'not_set'

pipeline {
    agent any

    environment {
        ARTEFACT="incubator-superset"
        CONTAINER_REGISTRY='eu.gcr.io/tm-preview'
        GIT_REPO_HOST_PATH="git@github.com:team-machine/${env.ARTEFACT}.git"
        GIT_REPO_BRANCH="tm-0.35.1-baseline"
        SNYK_TOKEN=credentials('SNYK_TOKEN')
    }

    stages {
        stage('Checkout') {
            steps {
//                 echo "${env.GIT_REPO_HOST_PATH}"
//                 git url: "${env.GIT_REPO_HOST_PATH}",
//                         credentialsId: 'tm-machine-account-creds'

                script {
//                     sshagent(['tm-machine-account-creds']) {
//                         sh "git pull origin ${env.GIT_REPO_BRANCH}"
//                     }

                    majorVer = sh(returnStdout: true, script: "git describe --tags --abbrev=0 | cut -d '.' -f1").trim()
	                minorVer = sh(returnStdout: true, script: "git describe --tags --abbrev=0 | cut -d '.' -f2").trim()
	                minorVer = 1 + minorVer.toInteger()
                    VERSION = "${majorVer}.${minorVer}"
                    echo "Building version ${VERSION}"
                }
            }
        }
        stage('Containerise') {
            steps {
                sh "docker build --build-arg build_version=${VERSION} -t ${env.ARTEFACT}:${VERSION} -t ${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:${VERSION} -t ${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:latest ."
            }
        }
        stage('Unit test') {
            steps {
                sh "docker run ${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:${VERSION} \
                    /bin/sh -c 'pip install -r dev_requirements.txt && python -m pytest tests/'"
            }
        }
        stage('Snyk package deps scan') {
            steps {
                // if we need to throttle, we can use  Calendar.DAY_OF_WEEK or similar
                sh "virtualenv snyk-tm-flow"
                sh "pip freeze --local | xargs pip uninstall -y || true"
                sh "pip install -r requirements.txt"
                sh "snyk test --file=requirements.txt"
            }
        }
        stage('Snyk container scan') {
            steps {
                sh "snyk test --docker ${env.ARTEFACT}:${VERSION}"
            }
        }
        stage('Tag VCS') {
            steps {
                sh "git config user.name ${GIT_USER_NAME}"
                sh "git config user.email ${GIT_USER_EMAIL}"

                echo 'Tagging and updating version in Git....'
                sh "git tag ${VERSION} -m 'Version ${VERSION}'"
                script {
                    sshagent(['tm-machine-account-creds']) {
                        sh "git push --follow-tags origin master"
                    }
                }
            }
        }
        stage('Push to Registry') {
            steps {
                sh "gcloud auth configure-docker"   // get docker to use gcloud creds
                sh "docker push '${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:${VERSION}'"
                sh "docker push '${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:latest'"
            }
        }
    }
}
