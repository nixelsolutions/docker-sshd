#!/bin/bash -e

USER=${USER:-$1}
USER_ID=${USER_ID:-$2}
GROUP_ID=${GROUP_ID:-$3}
USERADD_EXTRA_ARGS=${USERADD_EXTRA_ARGS:-$4}
PASSWORD=${PASSWORD:-$5}
HOME_DIR=${HOME_DIR:-$6}
ADD_TO_GROUPS=${ADD_TO_GROUPS:-$7}

HOME_DIR=${HOME_DIR:-/home/$USER}
USERADD_EXTRA_ARGS=${USERADD_EXTRA_ARGS:-"-m"}

if [ "${USER}" == "**ChangeMe**" -o -z "${USER}" ]; then
   echo "WARNING: you did not specify any value for USER environment variable - Ignoring ..."
   exit 0
fi

if getent passwd ${USER} >/dev/null; then
  echo "ERROR: user ${USER} already exists! Exiting ..."
  exit 1
fi

echo "=> Creating user ${USER} ..."
if echo ${USER_ID} | grep . >/dev/null; then
  USERADD_EXTRA_ARGS+=" -u ${USER_ID} -o"
fi
if echo ${GROUP_ID} | grep . >/dev/null; then
  USERADD_EXTRA_ARGS+=" -g ${GROUP_ID}"
fi
useradd -d ${HOME_DIR} -G sudo -s /bin/bash ${USERADD_EXTRA_ARGS} ${USER}

if [ "${PASSWORD}" == "**ChangeMe**" -o -z "${PASSWORD}" ]; then
   if [ "${PUBLIC_KEY}" == "**ChangeMe**" -o -z "${PUBLIC_KEY}" ]; then
      echo "ERROR: you did not specify any value for PASSWORD nor PUBLIC_KEY environment variables - Exiting..."
      exit 1
   else
      echo "=> Adding this public key for user ${USER}: ${PUBLIC_KEY}"
      mkdir -p ${HOME_DIR}/.ssh
      echo "${PUBLIC_KEY}" >> ${HOME_DIR}/.ssh/authorized_keys
      chown -R ${USER}:${USER} ${HOME_DIR}/.ssh
      chmod 750 ${HOME_DIR}/.ssh
   fi
else
   echo "=> Setting password for user ${USER} ..."
   echo "${USER}:${PASSWORD}" | chpasswd
fi

for group in `echo ${ADD_TO_GROUPS} | sed "s/,/ /g"`; do
  echo "=> Adding user ${USER} to group ${group} ..."
  usermod -a -G ${group} ${USER}
done

if [ a"${PERSIST_ETC_DIR}" != "a" -a -e ${PERSIST_ETC_DIR} ]; then
  cp -p /etc/{passwd,shadow,group} ${PERSIST_ETC_DIR}/
fi
