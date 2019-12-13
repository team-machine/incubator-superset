def timestamp = new Date().format('yyMMdd.HHmmss')

pipeline {
    agent any

    environment {
        ARTEFACT="incubator-superset"
        CONTAINER_REGISTRY='eu.gcr.io/tm-preview'
        GIT_REPO_HOST_PATH="git@github.com:team-machine/${env.ARTEFACT}.git"
        SUPERSET_BASE_VERSION="0.35.1"
        GIT_REPO_BRANCH="tm-${env.SUPERSET_BASE_VERSION}-baseline"
        IMAGE_VERSION="${env.SUPERSET_BASE_VERSION}-${timestamp}"
        SNYK_TOKEN=credentials('SNYK_TOKEN')
    }

    stages {
        stage('Containerise') {
            steps {
                echo "Building version ${env.IMAGE_VERSION}"
                sh "docker build --build-arg build_version=${env.IMAGE_VERSION} -t ${env.ARTEFACT}:${env.IMAGE_VERSION} -t ${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:${env.IMAGE_VERSION} -t ${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:latest ."
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
                sh "snyk test --docker ${env.ARTEFACT}:${env.IMAGE_VERSION}"
            }
        }
        stage('Tag VCS') {
            steps {
                sh "git config user.name ${GIT_USER_NAME}"
                sh "git config user.email ${GIT_USER_EMAIL}"

                echo 'Tagging and updating version in Git....'
                sh "git tag ${env.IMAGE_VERSION} -m 'Version ${env.IMAGE_VERSION}'"
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
                sh "docker push '${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:${env.IMAGE_VERSION}'"
                sh "docker push '${env.CONTAINER_REGISTRY}/${env.ARTEFACT}:latest'"
            }
        }
    }
}
