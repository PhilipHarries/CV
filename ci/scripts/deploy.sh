#!/usr/bin/env bash

echo "deploy"
yum -y install openssh-clients
mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
echo "${SSH_KEY}" > "${HOME}/.ssh/id_rsa"
chmod 400 "${HOME}/.ssh/id_rsa"

echo "Host ${TARGET_SERVER}
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no" > "${HOME}/.ssh/config"

echo user: "${SSH_USER}"
echo target: "${TARGET_SERVER}"
echo path: "${DEPLOY_PATH}"

scp -i "${HOME}/.ssh/id_rsa" ./CVrepo/CV/* "${SSH_USER}@${TARGET_SERVER}:${DEPLOY_PATH}"

exit 0
