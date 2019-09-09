#!/bin/bash

if [ "${USER}" == "**ChangeMe**" -o -z "${USER}" ]; then
   echo "ERROR: you did not specify any value for USER environment variable - Exiting..."
   exit 1
fi

if ! getent passwd ${USER} >/dev/null; then
  echo "=> Creating user ${USER} ..."
  if echo ${USER_ID} | grep . >/dev/null; then
    USERADD_EXTRA_ARGS+=" -u ${USER_ID} -o"
  fi
  if echo ${GROUP_ID} | grep . >/dev/null; then
    USERADD_EXTRA_ARGS+=" -g ${GROUP_ID}"
  fi
  useradd -d /home/${USER} -m -G sudo -s /bin/bash ${USERADD_EXTRA_ARGS} ${USER}
fi

if [ "${PASSWORD}" == "**ChangeMe**" -o -z "${PASSWORD}" ]; then
   if [ "${PUBLIC_KEY}" == "**ChangeMe**" -o -z "${PUBLIC_KEY}" ]; then
      echo "ERROR: you did not specify any value for PASSWORD nor PUBLIC_KEY environment variables - Exiting..."
      exit 1
   else
      echo "=> Adding this public key for user ${USER}: ${PUBLIC_KEY}"
      mkdir -p /home/${USER}/.ssh
      echo "${PUBLIC_KEY}" >> /home/${USER}/.ssh/authorized_keys
      chown -R ${USER}:${USER} /home/${USER}
      chmod 750 /home/${USER}/.ssh
   fi
else
   echo "=> Setting password for user ${USER} ..."
   echo "${USER}:${PASSWORD}" | chpasswd
fi

for group in `echo ${GROUPS} | sed "s/,/ /g"`; do
  echo "=> Adding user ${USER} to group ${group} ..."
  usermod -a -G www-data ${USER}
done

if [[ $# -lt 1 ]]; then
   exec /usr/sbin/sshd -D
fi

exec "$@"
