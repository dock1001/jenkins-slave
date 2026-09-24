#!/bin/sh
set -e

# Controller URL: JENKINS_MASTER, or the Kubernetes service environment
if [ -n "$JENKINS_MASTER" ]; then
  URL="$JENKINS_MASTER"
elif [ -n "$JENKINS_SERVICE_HOST" ] && [ -n "$JENKINS_SERVICE_PORT" ]; then
  URL="http://$JENKINS_SERVICE_HOST:$JENKINS_SERVICE_PORT"
else
  echo "Error: no controller URL. Set JENKINS_MASTER (e.g. http://jenkins:8080)." >&2
  exit 1
fi
# Strip trailing slashes
while [ "${URL%/}" != "$URL" ]; do
  URL="${URL%/}"
done

# Fetch the swarm client that matches the controller's Swarm plugin
if ! curl -fsSL --retry 10 --retry-delay 5 --retry-connrefused \
    -o "$HOME/swarm-client.jar" "$URL/swarm/swarm-client.jar"; then
  echo "Error: failed to download $URL/swarm/swarm-client.jar" >&2
  exit 1
fi

set -- -url "$URL" -webSocket
if [ -n "$JENKINS_USERNAME" ]; then
  set -- "$@" -username "$JENKINS_USERNAME"
fi
if [ -n "$JENKINS_PASSWORD" ]; then
  # The client reads the password from the environment, keeping it off the command line
  set -- "$@" -passwordEnvVariable JENKINS_PASSWORD
fi
if [ -n "$SLAVE_EXECUTORS" ]; then
  set -- "$@" -executors "$SLAVE_EXECUTORS"
fi
if [ -n "$SLAVE_LABELS" ]; then
  set -- "$@" -labels "$SLAVE_LABELS"
fi
if [ -n "$SLAVE_NAME" ]; then
  set -- "$@" -name "$SLAVE_NAME"
fi

echo "Connecting to $URL as ${JENKINS_USERNAME:-<anonymous>}"

# We utilize the shared volume for all instances
# shellcheck disable=SC3028 # Docker sets HOSTNAME in the container environment
exec java -jar "$HOME/swarm-client.jar" "$@" -fsroot "/var/jenkins/$HOSTNAME"
