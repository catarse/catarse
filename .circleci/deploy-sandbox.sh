#!/bin/sh
set -e

echo 'pushing to sandbox'
ssh-keyscan -t rsa ${SANDBOX_SSH_DOMAIN} >> "${HOME}/.ssh/known_hosts" > /dev/null
git remote add sandbox $SANDBOX_GIT_REMOTE 1> /dev/null
git push sandbox develop:master 1> /dev/null

