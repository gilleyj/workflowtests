#!/bin/bash
# V0.1
echo "DEIS deploy..."

# check for deis
deis_cmd=$(which deis)
if [ -z "${deis_cmd}" ] || [ ! -x ${deis_cmd} ] ; then
	echo "DEIS command does not exist, please run the deis_setup earlier in your deploy build..."
	exit 1
fi

# required variable testing blocks
if [ -z "$DEIS_HOME" ] || [ -z "$DEIS_USER" ] || [ -z "$DEIS_PASS" ]; then
	echo "ERROR: missing DEIS env variables"
	if [ -z "$DEIS_HOME" ]; then echo "Missing DEIS_HOME"; fi
	if [ -z "$DEIS_USER" ]; then echo "Missing DEIS_USER"; fi
	if [ -z "$DEIS_PASS" ]; then echo "Missing DEIS_PASS"; fi
	exit 1
fi

if [ -z "$CIRCLE_PROJECT_REPONAME" ] || [ -z "$CIRCLE_BRANCH" ] || [ -z "$CIRCLE_SHA1" ] || [ -z "$CIRCLE_BUILD_NUM" ]; then
	echo "ERROR: missing CIRCLECI env variables"
	if [ -z "$CIRCLE_PROJECT_REPONAME" ]; then echo "Missing CIRCLE_PROJECT_REPONAME"; fi
	if [ -z "$CIRCLE_BRANCH" ]; then echo "Missing CIRCLE_BRANCH"; fi
	if [ -z "$CIRCLE_SHA1" ]; then echo "Missing CIRCLE_SHA1"; fi
	if [ -z "$CIRCLE_BUILD_NUM" ]; then echo "Missing CIRCLE_BUILD_NUM"; fi
	exit 1
fi

SEND_SLACK=1
if [ -z "$SLACK_HOOK" ] || [ -z "$SLACK_CHANNEL" ]; then
	echo "ERROR: missing SLACK env variables"
	if [ -z "$SLACK_HOOK" ]; then echo "Missing SLACK_HOOK"; fi
	if [ -z "$SLACK_CHANNEL" ]; then echo "Missing SLACK_CHANNEL"; fi
	echo "this is not a fatal error..."
	SEND_SLACK=0
	# exit 1
fi

# send env vars
DEIS_NAME=${CIRCLE_PROJECT_REPONAME}-${CIRCLE_BRANCH}
DEIS_APP=${DEIS_NAME}.${DEIS_HOME}
DEIS_URL=http://${DEIS_APP}
export DEIS_ENV_CIRCLE_CI_BUILD=${CIRCLE_PROJECT_REPONAME}-${CIRCLE_BRANCH}-${CIRCLE_BUILD_NUM}
echo "Send DEIS_ENV_* ENV vars to app ${DEIS_NAME}..."
env | grep DEIS_ENV | sed 's/DEIS_ENV_*//g' | xargs deis config:set --app=${DEIS_NAME} || true
result=$?
if [[ $result != 0 ]]; then
	echo "DEIS APP ENVIRONMENT CONFIG SET ERROR OCCURED - (${result})"
	exit 1
else
	echo "DEIS app configuration success"
fi

echo "sleeping to make sure ECR catches up..."
sleep 6

# send code deploy
echo "Deploying to ${DEIS_URL}..."
git push ssh://git@deis-builder.$DEIS_HOME:2222/$DEIS_NAME.git $CIRCLE_SHA1:refs/heads/master -f
result=$?
if [[ $result != 0 ]]; then
	echo "DEIS DEPLOYMENT ERROR OCCURED - (${result})"
	echo "check to make sure you have DEIS_ENV_PORT set; it is the most common deployment issue."
	exit 1
else
	echo "DEIS app deployed to ${DEIS_URL}"
fi

if [[ $SEND_SLACK == 1 ]]; then
	SLACK_USER="${SLACK_USER:-DEIS CI}"
	SLACK_ICON="${SLACK_ICON:-robot_face}"
	SLACK_COLOR="${SLACK_COLOR:-1974D2}"
	# send off a deployment notification
	MSG_HEAD="App ${DEIS_NAME} (${CIRCLE_BUILD_NUM})"
	MSG_BODY="Deployed by ${CIRCLE_PROJECT_USERNAME} to <${DEIS_URL}|${DEIS_APP}>.\n(<${CIRCLE_BUILD_URL}|Circle CI build>)"
	if [ ! -z "$CIRCLE_COMPARE_URL" ]; then
		MSG_BODY="${MSG_BODY} (<${CIRCLE_COMPARE_URL}|github diff>)"
	fi
	json="{\"channel\": \"${SLACK_CHANNEL}\", \"username\":\"${SLACK_USER}\", \"icon_emoji\":\":${SLACK_ICON}:\", \"attachments\":[{ \"color\":\"${SLACK_COLOR}\" , \"title\":\"${MSG_HEAD}\" , \"mrkdwn_in\": [\"text\"], \"text\": \"${MSG_BODY}\"}]}"
	curl -s -d "payload=$json" ${SLACK_HOOK}
	result=$?
	echo
	if [[ $result != 0 ]]; then
		echo "SLACK NOTIFICATION OCCURED - (${result})"
		exit 1
	else
		echo "notification sent..."
	fi
else
	echo "Slack notification not sent..."
fi

echo "DEIS deploy complete..."
