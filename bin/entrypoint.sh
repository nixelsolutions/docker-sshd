#!/bin/bash

if ! grep -q "# Limit SFTP users" /etc/ssh/sshd_config; then
  echo "# Limit SFTP users
ChrootDirectory %h
ForceCommand internal-sftp
AllowTcpForwarding no
X11Forwarding no" >> /etc/ssh/sshd_config
fi

if [ a"${PERSIST_ETC_DIR}" != "a" -a -e ${PERSIST_ETC_DIR} ]; then
  cp -p ${PERSIST_ETC_DIR}/* /etc/
fi

/usr/local/bin/add_user.sh

if [[ $# -lt 1 ]]; then
   exec /usr/sbin/sshd -D
fi

exec "$@"
