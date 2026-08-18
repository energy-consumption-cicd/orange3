#!/usr/bin/env bash

set -euo pipefail
STAGE="${1:?stage required}"

export ORANGE_DEPRECATIONS_ERRORR=y
export PYTHONWARNINGS=module
export COVERAGE_FILE=/project/.coverage
export COVERAGE_RCFILE=/project/.coveragerc

export XVFBARGS="-screen 0 1280x1024x24"

export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

cd /project

case "$STAGE" in

  build)
    rm -rf /tmp/venv-build
    python3.11 -m venv /tmp/venv-build

    /tmp/venv-build/bin/pip install \
        'pyqt5==5.15.*' 'pyqtwebengine==5.15.*' \
        coverage psycopg2-binary pymssql

    /tmp/venv-build/bin/pip install /project

    /tmp/venv-build/bin/pip check
    /tmp/venv-build/bin/pip freeze
    ;;

  test)
    cd "$(python -c 'import site; print(site.getsitepackages()[0])')"

    local_test_exit=0
    set +e
    catchsegv xvfb-run -a -s "$XVFBARGS" \
        coverage run -m unittest -v Orange.tests Orange.widgets.tests
    local_test_exit=$?
    set -e

    cov_exit=0
    coverage combine                      || cov_exit=$?
    coverage report                       || cov_exit=$?
    coverage xml -o /project/coverage.xml || cov_exit=$?

    if [ "$local_test_exit" -ne 0 ]; then
        echo "commands.sh: unittest saiu com $local_test_exit; coverage combine/report/xml executaram; propagando $local_test_exit" >&2
        exit "$local_test_exit"
    fi
    exit "$cov_exit"
    ;;

  *)
    echo "Stage desconhecido: $STAGE" >&2
    exit 1
    ;;
esac
