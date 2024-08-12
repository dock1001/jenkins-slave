# jenkins-slave-u22_04

Ubuntu 22.04
- Docker support
- Jenkins swarm

Intended to work in collaboration with [jenkins-master](https://github.com/dock1001/jenkins-master)

## Jenkin swarm slaves

### Running

To run a Docker container customizing the different tools with your credentials

    docker run \
    -e JENKINS_USERNAME=jenkins \
    -e JENKINS_PASSWORD=jenkins \
    -e JENKINS_MASTER=http://jenkins:8080 \
    rancher/jenkins-slave

### Optional Environment Variables

You can specify optional environment variables below when invoking docker run to customize the behavior of the swarm client.

| Parameter       | Default Value       | Description                                                                |
|-----------------|---------------------|----------------------------------------------------------------------------|
| SLAVE_EXECUTORS | number of cpu cores | This value specifies the number of concurrent jobs this worker can process |
| SLAVE_NAME      | swarm-client        | This value specifies the name of slave that will appear on Jenkins UI      |
| SLAVE_LABELS    | None                | This value specifies the labels you want to give for the launching slave   |
