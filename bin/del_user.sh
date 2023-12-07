#!/bin/bash -e

USER=${USER:-$1}
echo "Deleting user ${USER} ..."
userdel ${USER}

if [ a"${PERSIST_ETC_DIR}" != "a" -a -e ${PERSIST_ETC_DIR} ]; then
  cp -p /etc/{passwd,shadow,group} ${PERSIST_ETC_DIR}/
fi
