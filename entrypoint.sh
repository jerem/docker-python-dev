#!/bin/bash
set -e

if [ ! -e /venv/bin/python ]; then
    virtualenv /venv
fi

export VIRTUAL_ENV="/venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"

if [ -z "$REQUIREMENTS_FILE" ]; then
    REQUIREMENTS_FILE="/app/requirements.txt"
fi

md5sum "$REQUIREMENTS_FILE" > /pipcache/new_sum.txt
if ! cmp -s /pipcache/sum.txt /pipcache/new_sum.txt > /dev/null; then
    pip install --download /pipcache -r "$REQUIREMENTS_FILE"
    pip install --find-links /pipcache -r "$REQUIREMENTS_FILE"
    mv /pipcache/new_sum.txt /pipcache/sum.txt
fi

exec "$@"