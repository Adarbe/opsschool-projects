node('base-slave') {
cleanWs()
stage('SCM CHECKOUT') {
git branch: "master", url: 'git@github.com:Adarbe/card_validation.git';
}
stage('Docker build & push') {
app = docker.build( “adarbe/mid_project_git:${commitHash}_${BUILD_NUMBER}", " --no-cache ." )
app.run("-p 8080:8080")
curl -L localhost:8080
app.push()
sh( script: "docker rmi ${app.id}" )
}
}
