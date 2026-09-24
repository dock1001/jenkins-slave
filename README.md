# jenkins-slave

A Jenkins agent image that connects to the controller with the Swarm plugin.

- Ubuntu 26.04
- OpenJDK 21 (headless)
- Docker CLI + buildx, using the host's Docker daemon
- Swarm client downloaded from the controller at startup, so it always matches the controller's Swarm plugin
- `git`, `lftp` and `rsync`

Intended to work in collaboration with [jenkins-master](https://github.com/dock1001/jenkins-master)

## Tags

| Branch         | Tag      |
|----------------|----------|
| `master`       | `latest` |
| other branches | `dev`    |

## Running

    docker run -d \
      --group-add <gid> \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -e JENKINS_MASTER=http://jenkins:8080 \
      -e JENKINS_USERNAME=jenkins \
      -e JENKINS_PASSWORD=<api-token> \
      <dockerhub-user>/jenkins-slave:latest

### Docker socket

Builds run `docker` against the host's daemon through the mounted socket. The agent runs as `jenkins-slave` (UID 1000), so it needs the socket's group. `<gid>` is the output of this command on the host:

    stat -c %g /var/run/docker.sock

### Credentials

`JENKINS_PASSWORD` should be a Jenkins **API token** for `JENKINS_USERNAME`, not the account password. The entrypoint passes it to the swarm client with `-passwordEnvVariable`, so it never appears on the command line or in the log.

### WebSocket

The agent connects over WebSocket on the controller's web port (the same port as `JENKINS_MASTER`), so the controller doesn't need to expose the inbound agent port 50000.

## Environment variables

| Variable           | Default                                   | Description                                                                          |
|--------------------|-------------------------------------------|--------------------------------------------------------------------------------------|
| `JENKINS_MASTER`   | none (required)                           | Controller URL, e.g. `http://jenkins:8080`. On Kubernetes, `http://$JENKINS_SERVICE_HOST:$JENKINS_SERVICE_PORT` is used when this is unset |
| `JENKINS_USERNAME` | none (anonymous)                          | Jenkins user the agent connects as                                                   |
| `JENKINS_PASSWORD` | none                                      | API token for `JENKINS_USERNAME`                                                     |
| `SLAVE_EXECUTORS`  | number of CPU cores                       | Number of concurrent builds this agent runs                                          |
| `SLAVE_LABELS`     | none                                      | Space-separated labels, e.g. `docker linux`                                          |
| `SLAVE_NAME`       | container hostname, plus a unique suffix  | Agent name shown in the Jenkins UI                                                   |

The agent's workspace is `/var/jenkins/$HOSTNAME` on the `/var/jenkins` volume, so several agents can share one volume.
