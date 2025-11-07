#! /bin/sh

export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

cd /jenkins/jenkins-agent-scripts || exit 1

if [ -r agent.conf ]; then
	. agent.conf
fi

for i in master secret; do
	eval v=\$$i
	if [ -z "${v}" ]; then
		echo "${i} is not defined" >&2
		exit 1
	fi
done

if [ -z "${agentname}" ]; then
	agentname=`/bin/hostname`
fi

if [ -n "${nice_increment}" ] && [ ${nice_increment} -ne 0 ]; then
	NICE_CMD="/usr/bin/nice -n ${nice_increment}"
fi

while [ ! -f agent.dontstart ]
do
	/bin/date
	# mirror mode, update it if there's a timestamp change on the master
	/usr/bin/fetch -m -o agent.jar "https://${master}/jnlpJars/agent.jar"
	${NICE_CMD} /usr/local/bin/java \
		-Djava.net.preferIPv6Addresses=true \
		-Djava.net.preferIPv4Stack=false \
		-jar agent.jar \
		-url "https://${master}/computer/${agentname}/jenkins-agent.jnlp" \
		-secret "${secret}" \
		-name ${agentname} \
		-webSocket
	/bin/sleep 30
done
