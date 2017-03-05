#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -u

echo "checking if html tidy is present..."
if ! which tidy >/dev/null 2>&1;then
   echo "html tidy is not present"
   latest_url="$(curl -sI https://github.com/htacg/tidy-html5/releases/latest|grep Location:|awk '{print $2}'|sed s///g)"
   latest_semver="$(echo ${latest_url}|awk -F/ '{print $NF}')"
   # test if rpm or deb system:
  if /usr/bin/rpm -q -f /usr/bin/rpm >/dev/null;then
    # likely rpm
    file="tidy-${latest_semver}-64bit.rpm"
    url="https://github.com/htacg/tidy-html5/releases/download/${latest_semver}/${file}"
    echo "fetching ${url}"
    curl -LO "${url}"
    if which dnf >/dev/null 2>&1;then
      dnf install -y "./${file}"
    else
      yum install -y "./${file}"
    fi
  else
    # likely deb
    file="tidy-${latest_semver}-64bit.deb"
    url="${latest_url}/${file}"
    mkdir -p /tmp/tidy
    curl -so "/tmp/tidy/${file}" "${url}"
    (
      cd /tmp/tidy
      dpkg -i "${file}"
      apt-get install -f
    )
  fi
fi

pwd
ls
tidy --drop-empty-elements no ./CVrepo/CV.html

if [[ ${?} -eq 0 ]];then
  echo "Test passed successfully"
  exit 0
else
  echo "HTML linting failed"
  exit 1
fi
