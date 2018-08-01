#!/bin/bash
# V0.1
echo "DEIS integration setup..."

# required variable testing blocks
if [ -z "$DEIS_HOME" ] || [ -z "$DEIS_USER" ] || [ -z "$DEIS_PASS" ]; then
  echo "ERROR: missing DEIS env variables"
  if [ -z "$DEIS_HOME" ]; then echo "Missing DEIS_HOME"; fi
  if [ -z "$DEIS_USER" ]; then echo "Missing DEIS_USER"; fi
  if [ -z "$DEIS_PASS" ]; then echo "Missing DEIS_PASS"; fi
  exit 1
fi

if [ -z "$CIRCLE_PROJECT_REPONAME" ] || [ -z "$CIRCLE_BRANCH" ]; then
  echo "ERROR: missing CIRCLECI env variables"
  if [ -z "$CIRCLE_PROJECT_REPONAME" ]; then echo "Missing CIRCLE_PROJECT_REPONAME"; fi
  if [ -z "$CIRCLE_BRANCH" ]; then echo "Missing CIRCLE_BRANCH"; fi
  if [ -z "$DEIS_PASS" ]; then echo "Missing DEIS_PASS"; fi
  exit 1
fi

# setup remote signature for deis git interaction
echo "Setup known_hosts..."
ssh_dir=$HOME/.ssh
keyscan=$(which ssh-keyscan)
if [ ! -d ${ssh_dir} ] ; then
	echo "${ssh_dir} does not exist, creating it"
	mkdir -p ${ssh_dir}
fi
if [ ! -f ${ssh_dir}/known_hosts ] ; then
	echo "${ssh_dir}/known_hosts does not exists, creating it"
	touch ${ssh_dir}/known_hosts
fi
if [ -z "${keyscan}" ] || [ ! -x ${keyscan} ] ; then
	echo "ERROR: ssh-keyscan not found/not executable..."
	exit 1
else
	echo "Getting fingerprint for deis-builder.$DEIS_HOME"
	$keyscan -t ecdsa -p 2222 -H deis-builder.$DEIS_HOME >> ${ssh_dir}/known_hosts
	echo "Sorting for uniq known_hosts"
	sort -u ${ssh_dir}/known_hosts > ${ssh_dir}/known_hosts.tmp
	mv ${ssh_dir}/known_hosts.tmp ${ssh_dir}/known_hosts
fi

deis_cmd=$(which deis)
if [ -z "${deis_cmd}" ] || [ ! -x ${deis_cmd} ] ; then
	echo "Download and install DEIS (requires sudo permissions to move to /usr/local/bin/deis)..."
	# this downloads an install script and installs deis to the current directory IE $PWD
	curl -sSL http://deis.io/deis-cli/install-v2.sh | bash
	sudo mv $PWD/deis /usr/local/bin/deis
	deis_cmd=/usr/local/bin/deis
else
	echo "DEIS command exists..."
fi

echo "Login to DEIS..."
$deis_cmd login http://deis.$DEIS_HOME --username $DEIS_USER --password $DEIS_PASS
result=$?
if [[ $result != 0 ]]; then
	echo "DEIS LOGIN ERROR OCCURED - (${result})"
	exit 1
else
	echo "DEIS login success"
fi

echo "Test ability to push to deis-builder..."
git ls-remote ssh://git@deis-builder.$DEIS_HOME:2222/
result=$?
if [[ $result != 0 ]]; then
	echo "DEIS SSH AUTHENTICATION ERROR OCCURED - (${result})"
	echo "you will need to run something like deis keys:add ~/.ssh/id_rsa.pub to continue..."
	exit 1
else
	echo "DEIS ssh authentication test passed"
fi

echo "check for existing app..."
DEIS_NAME=${CIRCLE_PROJECT_REPONAME}-${CIRCLE_BRANCH}
deis info --app ${DEIS_NAME}
result=$?
if [[ $result != 0 ]]; then
	echo "no DEIS app named ${DEIS_NAME} found... creating"
	deis create --no-remote ${DEIS_NAME}
	result=$?
	if [[ $result != 0 ]]; then
		echo "DEIS APP CREATE ERROR OCCURED - (${result})"
		exit 1
	fi
fi

echo "DEIS integration setup complete..."
echo "It will take a few moments before the ECR gets authentication credentials"
