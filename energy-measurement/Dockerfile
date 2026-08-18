
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y \
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        git \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
        libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcb-xfixes0 \
        libxcb-shape0 libxcb-cursor0 glibc-tools libegl1 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        xvfb \
        libgl1 libglib2.0-0 libdbus-1-3 libfontconfig1 libfreetype6 \
        libxcb1 libx11-xcb1 libxcb-sync1 libxcb-util1 libxcb-glx0 \
        libxcb-shm0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 \
        libnss3 libnspr4 libasound2t64 libxcomposite1 libxdamage1 \
        libxrandr2 libxtst6 libcups2t64 libdrm2 libgbm1 \
        libpango-1.0-0 libatk1.0-0t64 libatk-bridge2.0-0t64 libatspi2.0-0t64 \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        libxfixes3 \
        libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
        libpulse0 libpulse-mainloop-glib0 \
        libwayland-cursor0 libwayland-egl1 \
    && rm -rf /var/lib/apt/lists/*

RUN userdel -r ubuntu && \
    groupadd -g 1000 medicao && \
    useradd -u 1000 -g 1000 -m -d /home/medicao -s /bin/bash medicao && \
    mkdir -p /venv /wheelhouse /src-install && \
    chown medicao:medicao /venv /wheelhouse /src-install && \
    id medicao

USER medicao
ENV HOME=/home/medicao

RUN python3.11 -m venv /venv
ENV VIRTUAL_ENV=/venv
ENV PATH="/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel

COPY --chown=medicao:medicao . /project
WORKDIR /project

RUN cp -a /project/. /src-install/

RUN pip wheel --wheel-dir=/wheelhouse \
        'pyqt5==5.15.*' 'pyqtwebengine==5.15.*' \
        coverage psycopg2-binary pymssql \
        -r /project/requirements-core.txt \
        -r /project/requirements-gui.txt \
        'cython>=3.0' 'numpy>=2.0' recommonmark 'setuptools>=51.0' \
        'sphinx>=4.2.0,<8' sphinx-multiproject myst-parser wheel \
        'trubar>=0.3.4'

RUN if ls /wheelhouse | grep -iE '^orange3-'; then \
        echo "FAIL: pre-built orange3 wheel in the wheelhouse - the measured build would not compile" >&2; \
        exit 1; \
    fi; \
    echo "GATE 1 OK: nenhuma wheel de orange3 no wheelhouse ($(ls /wheelhouse | wc -l) wheels)"

RUN pip install --no-index --find-links=/wheelhouse \
        'pyqt5==5.15.*' 'pyqtwebengine==5.15.*' \
        coverage psycopg2-binary pymssql
RUN PIP_NO_INDEX=1 PIP_FIND_LINKS=/wheelhouse pip install /src-install

ENV PIP_NO_INDEX=1
ENV PIP_FIND_LINKS=/wheelhouse

RUN cd /project && \
    if [ -e build ] || [ -e Orange3.egg-info ] || [ -e Orange/version.py ] || \
       [ -n "$(find Orange -name '*.so' -print -quit)" ]; then \
        echo "FAIL: /project contaminated with build artifacts - the build stage would measure incremental compilation" >&2; \
        find . -maxdepth 2 \( -name build -o -name '*.egg-info' -o -name version.py \) >&2; \
        exit 1; \
    fi; \
    echo "GATE 2 OK: /project pristine - every measured run compiles the 11 modules from scratch"

RUN N=$(find /venv -name '*.so' -path '*/Orange/*' | wc -l); \
    echo "compiled extensions in /venv: $N"; \
    find /venv -name '*.so' -path '*/Orange/*' | sort; \
    [ "$N" -ge 11 ] || (echo "FAIL: expected >= 11 compiled extensions, found $N" >&2; exit 1); \
    echo "GATE 3 OK"

RUN cd /tmp && xvfb-run -a python -c \
    "from Orange.widgets.utils.webview import WebviewWidget; print('GATE 4 OK: WebEngine OK')"

RUN FALTANDO=$(for d in /venv/lib/python3.11/site-packages/PyQt5/Qt5/lib \
                        /venv/lib/python3.11/site-packages/PyQt5/Qt5/plugins/platforms \
                        /venv/lib/python3.11/site-packages/PyQt5/Qt5/libexec \
                        /venv/lib/python3.11/site-packages/PyQt5; do \
        [ -d "$d" ] && find "$d" -maxdepth 1 \( -name '*.so*' -o -name 'QtWebEngineProcess' \) 2>/dev/null; \
      done | while read -r f; do ldd "$f" 2>/dev/null | grep 'not found'; done | sed 's/^[[:space:]]*//' | sort -u); \
    if [ -n "$FALTANDO" ]; then \
        echo "FAIL: unresolved dynamic dependencies in PyQt5/WebEngine:" >&2; \
        echo "$FALTANDO" >&2; \
        exit 1; \
    fi; \
    echo "GATE 5 OK: zero unresolved dynamic dependencies in PyQt5/WebEngine"

RUN pip list

USER root

COPY --from=prebake core/            /opt/prebake/www/core/
COPY --from=prebake SHA256SUMS       /opt/prebake/SHA256SUMS
COPY --from=prebake serve_datasets.py /opt/prebake/serve_datasets.py
COPY --from=prebake gate6.py         /opt/prebake/gate6.py
COPY --from=prebake entrypoint.sh    /usr/local/bin/medicao-entrypoint.sh

RUN set -eu; \
    mkdir -p /opt/prebake/tls; \
    openssl req -x509 -newkey rsa:2048 -sha256 -days 36500 -nodes \
        -keyout /opt/prebake/tls/ca.key -out /opt/prebake/tls/ca.crt \
        -subj "/CN=medicao prebake CA" \
        -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" 2>/dev/null; \
    openssl req -newkey rsa:2048 -sha256 -nodes \
        -keyout /opt/prebake/tls/server.key -out /tmp/server.csr \
        -subj "/CN=datasets.biolab.si" 2>/dev/null; \
    printf 'subjectAltName=DNS:datasets.biolab.si\nextendedKeyUsage=serverAuth\nbasicConstraints=critical,CA:FALSE\n' \
        > /tmp/server.ext; \
    openssl x509 -req -in /tmp/server.csr -sha256 -days 36500 \
        -CA /opt/prebake/tls/ca.crt -CAkey /opt/prebake/tls/ca.key \
        -CAcreateserial -extfile /tmp/server.ext \
        -out /opt/prebake/tls/server.crt 2>/dev/null; \
    cp /opt/prebake/tls/ca.crt /usr/local/share/ca-certificates/medicao-prebake.crt; \
    update-ca-certificates; \
    chmod 0644 /opt/prebake/tls/server.key /opt/prebake/tls/server.crt; \
    chmod 0755 /usr/local/bin/medicao-entrypoint.sh; \
    rm -f /tmp/server.csr /tmp/server.ext /opt/prebake/tls/ca.key \
          /opt/prebake/tls/ca.srl; \
    openssl x509 -in /opt/prebake/tls/server.crt -noout -text \
        | grep -A1 'Subject Alternative Name'

USER medicao

RUN cd /opt/prebake/www/core && sha256sum -c /opt/prebake/SHA256SUMS && \
    python /opt/prebake/gate6.py

ENTRYPOINT ["/usr/local/bin/medicao-entrypoint.sh"]
