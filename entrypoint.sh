#!/bin/bash
set -e

export VIRTUAL_ENV="/venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
export PIP_ACCEL_CACHE="/pipcache"

parse_pip()
{
  pip_file="$1"
  echo $pip_file

  for i in `grep '^\s*\-r' $pip_file | sed s/^\s*\-r//`
  do
    dep="$(dirname $pip_file)/$i"
    parse_pip "$dep"
  done
}

if [ -z "$REQUIREMENTS_FILE" ]; then
  REQUIREMENTS_FILE="/app/requirements.txt"
fi

if [ -f "$REQUIREMENTS_FILE" ]; then
  > /pipcache/new_sum.txt
  for f in `parse_pip "$REQUIREMENTS_FILE"`
  do
    md5sum "$f" >> /pipcache/new_sum.txt
  done

  if ! cmp -s /pipcache/sum.txt /pipcache/new_sum.txt > /dev/null; then
    rm -fr /venv/* &&
    virtualenv /venv &&
    pip install --exists-action w --download /pipcache pip-accel &&
    pip install --exists-action w --find-links /pipcache pip-accel &&
    pip-accel install -r "$REQUIREMENTS_FILE" &&
    mv /pipcache/new_sum.txt /pipcache/sum.txt || exit $?
  fi
fi

exec "$@"