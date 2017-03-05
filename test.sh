#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -u

if ! which tidy >/dev/null 2>&1;then
   # need to install htmltidy
   latest_url="$(curl -sI https://github.com/htacg/tidy-html5/releases/latest|grep Location:|awk '{print $2}'|sed s///g)"
   latest_semver="$(echo ${latest_url}|awk -F/ '{print $NF}')"
   # test if rpm or deb system:
  if /usr/bin/rpm -q -f /usr/bin/rpm >/dev/null;then
    # likely rpm
    file="tidy-${latest_semver}-64bit.rpm"
    url="${latest_url}/${file}"
    curl -so /tmp/tidy-${latest_semver}-64bit.rpm "${url}"
    if which dnf >/dev/null 2>&1;then
      sudo dnf install -y "/tmp/${file}"
    else
      sudo yum install -y "/tmp/${file}"
    fi
  else
    # likely deb
    file="tidy-${latest_semver}-64bit.deb"
    url="${latest_url}/${file}"
    mkdir -p /tmp/tidy
    curl -so "/tmp/tidy/${file}" "${url}"
    (
      cd /tmp/tidy
      sudo dpkg -i "${file}"
      sudo apt-get install -f
    )
  fi
fi
tidy --drop-empty-elements no ./CV.html

if [[ ${?} -eq 0 ]];then
  echo "Test passed successfully"
  exit 0
else
  echo "HTML linting failed"
  exit 1
fi
