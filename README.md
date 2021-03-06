
# jenkins-jnlp-slave
jenkins-jnlp-slave

## Environment variables

- CI_OPT_GIT_AUTH_TOKEN
> see docker-gitlab/gitlab-runner for more info

- JENKINS_URL
> see following sections for more info

## Manually provision slaves (Create slave in jenkins web console)

- `export CI_OPT_GIT_AUTH_TOKEN=<your_CI_OPT_GIT_AUTH_TOKEN>`

- Open jenkins '/computer' URL (e.g. http://jenkins:18083/computer/)
  Create 'Permanent Agent' with  
  'Name'='<slave_name>'  
  'Launcher'='Launch agent via Java Web Start' (hudson.slaves.JNLPLauncher)  
  'Remote Working Directory'='/home/jenkins/.jenkins'

- Find out secret
  Run following 2 lines in script console (secret isn't visible using the API or even jenkins-cli)

```
for (aSlave in hudson.model.Hudson.instance.slaves) {
  println "export JENKINS_URL=\"" + Hudson.instance.getRootUrl() + "\""
  println "export JENKINS_JNLP_SLAVE_COMMAND=\"" + aSlave.getComputer().getJnlpMac() + " " + aSlave.name + "\""
}
```

- `export JENKINS_URL="http://jenkins:8080"`
- `export JENKINS_JNLP_SLAVE_COMMAND="<secret> <slave_name>"`

<del>
## Auto-provision slaves (sending user with -credentials <username>:<token>)

Not work since version 3.27

- `export CI_OPT_GIT_AUTH_TOKEN=<your_CI_OPT_GIT_AUTH_TOKEN>`

- Open jenkins '/computer' URL (e.g. http://jenkins:18083/computer/)
  Create 'Permanent Agent' with  
  'Name'='<slave_name>'  
  'Launcher'='Launch agent via Java Web Start' (hudson.slaves.JNLPLauncher)  
  'Remote Working Directory'='/home/jenkins/.jenkins'

- Create a user and login as it to get token

- `export JENKINS_URL="http://jenkins:8080/computer/<slave_name>/slave-agent.jnlp -credentials <username>:<token>"`
</del>

## Provision on k8s

- Do steps in 'Auto-provision slaves' section

- `cd k8s`

- Generate jenkins-jnlp-slave-secret.yaml

```sh
sed "s#<PUT_BASE64_CI_OPT_GIT_AUTH_TOKEN_HERE_MANUALLY>#$(echo -n ${CI_OPT_GIT_AUTH_TOKEN} | base64 -w 0)#" jenkins-jnlp-slave-secret.template | \
sed "s#<PUT_JENKINS_URL_HERE_MANUALLY>#$(echo -n ${JENKINS_URL} | base64 -w 0)#" \
> jenkins-jnlp-slave-secret.yaml
```

- Run `kubectl create -f jenkins-jnlp-slave-secret.yaml` and `kubectl create -f jenkins-jnlp-slave-deploy.yaml` to deploy

- `kubectl get po` to see jenkins-jnlp-slave's pod

## Note

This should be done by a cron script on host that fix permission of '/var/run/docker.sock' periodically

```
sudo chmod a+rw /var/run/docker.sock
```

## References

[https://hub.docker.com/r/jenkinsci/jnlp-slave/](https://hub.docker.com/r/jenkinsci/jnlp-slave/)
[https://github.com/jenkinsci/docker-jnlp-slave](https://github.com/jenkinsci/docker-jnlp-slave)

[https://hub.docker.com/r/jenkinsci/slave/](https://hub.docker.com/r/jenkinsci/slave/)
[https://github.com/jenkinsci/docker-slave](https://github.com/jenkinsci/docker-slave)


[defunct sh and sleep processes](https://github.com/jenkinsci/docker-jnlp-slave/issues/51)
[Handling of zombie processes would be useful](https://github.com/jenkinsci/docker/issues/54)
