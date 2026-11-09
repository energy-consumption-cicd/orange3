
# Runner ubuntu-20.04 of the tag commit (2022-12-05) is Ubuntu 20.04: the image of that date. The archive snapshot is
# the earliest the snapshot service holds for the focal update pockets (they return 404 before 2023-03-01).
FROM ubuntu:focal-20221130@sha256:0e0402cd13f68137edb0266e1d2c682f217814420f2d43d300ed8f65479b14fb

ARG APT_SNAPSHOT=20230301T000000Z

ENV DEBIAN_FRONTEND=noninteractive

# ca-certificates comes from the current archive only to reach the snapshot service over https.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    sed -i "s#http://archive.ubuntu.com/ubuntu/#https://snapshot.ubuntu.com/ubuntu/${APT_SNAPSHOT}/#; s#http://security.ubuntu.com/ubuntu/#https://snapshot.ubuntu.com/ubuntu/${APT_SNAPSHOT}/#" \
        /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# actions/setup-python: the linux-20.04-x64 build of the latest 3.10 patch published before the tag commit; 3.10 is the highest cell of the tag matrix (3.8, 3.9, 3.10).
ARG PYTHON_VERSION=3.10.8
ARG PYTHON_RELEASE=3.10.8-3271105491
ARG PYTHON_SHA256=79af97009f73fefac901a4c572d2e624e900ee1e24152d9b226a522ba0d116a6
RUN set -eux; \
    dest=/opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64; \
    mkdir -p "$dest"; \
    curl -fsSL -o /tmp/python.tar.gz \
        "https://github.com/actions/python-versions/releases/download/${PYTHON_RELEASE}/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz"; \
    echo "${PYTHON_SHA256}  /tmp/python.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/python.tar.gz -C "$dest"; \
    rm -f /tmp/python.tar.gz "$dest/setup.sh"; \
    ln -s "$dest/bin/python3.10" /usr/local/bin/python3.10; \
    python3.10 --version

# The apt step of the tag; catchsegv ships in libc-bin on 20.04, so no glibc-tools package is installed.
RUN apt-get update && \
    apt-get install -y \
        libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
        libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcb-xfixes0 \
        libegl1-mesa libxcb-shape0 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        xvfb \
        libgl1 libglib2.0-0 libdbus-1-3 libfontconfig1 libfreetype6 \
        libxcb1 libx11-xcb1 libxcb-sync1 libxcb-util1 libxcb-glx0 \
        libxcb-shm0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 \
        libnss3 libnspr4 libasound2 libxcomposite1 libxdamage1 \
        libxrandr2 libxtst6 libcups2 libdrm2 libgbm1 \
        libpango-1.0-0 libatk1.0-0 libatk-bridge2.0-0 libatspi2.0-0 \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# libxi6 is pulled in by other packages on 22.04 and 24.04; on 20.04 the Qt 5.15.2 wheel needs it listed.
RUN apt-get update && \
    apt-get install -y \
        libxfixes3 libxcursor1 libxi6 \
        libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
        libpulse0 libpulse-mainloop-glib0 \
        libwayland-cursor0 libwayland-egl1 \
    && rm -rf /var/lib/apt/lists/*

# The Ubuntu 20.04 image has no default user holding uid 1000.
RUN groupadd -g 1000 medicao && \
    useradd -u 1000 -g 1000 -m -d /home/medicao -s /bin/bash medicao && \
    mkdir -p /venv /wheelhouse /src-install && \
    chown medicao:medicao /venv /wheelhouse /src-install && \
    id medicao

USER medicao
ENV HOME=/home/medicao

RUN python3.10 -m venv /venv
ENV VIRTUAL_ENV=/venv
ENV PATH="/venv/bin:$PATH"

RUN pip install --upgrade pip==22.3.1 setuptools==65.6.3 wheel==0.38.4

COPY --chown=medicao:medicao . /project
WORKDIR /project

RUN cp -a /project/. /src-install/

# The tag pins no versions: what pip resolved against the index as of the tag commit (2022-12-05T14:28:50Z).
COPY <<'EOF' /constraints.txt
anyio==3.6.2
anyqt==0.2.0
asttokens==2.2.1
backcall==0.2.0
baycomp==1.0.2
bottleneck==1.3.5
cachecontrol==0.12.11
catboost==1.1.1
certifi==2022.9.24
cffi==1.15.1
chardet==5.1.0
charset-normalizer==2.1.1
commonmark==0.9.1
contourpy==1.0.6
coverage==6.5.0
cryptography==38.0.4
cycler==0.11.0
debugpy==1.6.4
decorator==5.1.1
dictdiffer==0.9.0
docutils==0.19
entrypoints==0.4
et-xmlfile==1.1.0
executing==1.2.0
fonttools==4.38.0
graphviz==0.20.1
h11==0.14.0
httpcore==0.16.2
httpx==0.23.1
idna==3.4
importlib-metadata==5.1.0
ipykernel==6.17.1
ipython-genutils==0.2.0
ipython==8.7.0
jaraco-classes==3.2.3
jedi==0.18.2
jeepney==0.8.0
joblib==1.2.0
jupyter-client==7.4.8
jupyter-core==5.1.0
keyring==23.11.0
keyrings-alt==4.2.0
kiwisolver==1.4.4
lockfile==0.12.2
matplotlib-inline==0.1.6
matplotlib==3.6.2
more-itertools==9.0.0
msgpack==1.0.4
nest-asyncio==1.5.6
networkx==2.8.8
numpy==1.23.5
openpyxl==3.0.10
opentsne==0.6.2
orange-canvas-core==0.1.29
orange-widget-base==4.19.0
packaging==21.3
pandas==1.5.2
parso==0.8.3
pexpect==4.8.0
pickleshare==0.7.5
pillow==9.3.0
pip==22.3.1
platformdirs==2.5.4
plotly==5.11.0
prompt-toolkit==3.0.33
psutil==5.9.4
psycopg2-binary==2.9.5
ptyprocess==0.7.0
pure-eval==0.2.2
pycparser==2.21
pygments==2.13.0
pyparsing==3.0.9
pyqt5-qt5==5.15.2
pyqt5-sip==12.11.0
pyqt5==5.15.7
pyqtgraph==0.13.1
pyqtwebengine-qt5==5.15.2
pyqtwebengine==5.15.6
python-dateutil==2.8.2
python-louvain==0.16
pytz==2022.6
pyyaml==6.0
pyzmq==24.0.1
qasync==0.23.0
qtconsole==5.4.0
qtpy==2.3.0
requests==2.28.1
rfc3986==1.5.0
scikit-learn==1.1.3
scipy==1.9.3
secretstorage==3.3.3
serverfiles==0.3.1
setuptools==65.6.3
six==1.16.0
sniffio==1.3.0
stack-data==0.6.2
tenacity==8.1.0
threadpoolctl==3.1.0
tornado==6.2
traitlets==5.6.0
typing-extensions==4.4.0
urllib3==1.26.13
wcwidth==0.2.5
xgboost==1.7.1
xlrd==2.0.1
xlsxwriter==3.0.3
zipp==3.11.0
EOF
COPY <<'EOF' /constraints-build.txt
alabaster==0.7.12
babel==2.11.0
certifi==2022.9.24
charset-normalizer==2.1.1
commonmark==0.9.1
cython==0.29.32
docutils==0.19
idna==3.4
imagesize==1.4.1
jinja2==3.1.2
markupsafe==2.1.1
numpy==1.21.6
oldest-supported-numpy==2022.11.19
packaging==21.3
pygments==2.13.0
pyparsing==3.0.9
pytz==2022.6
recommonmark==0.7.1
requests==2.28.1
setuptools==49.6.0
snowballstemmer==2.2.0
sphinx==5.3.0
sphinxcontrib-applehelp==1.0.2
sphinxcontrib-devhelp==1.0.2
sphinxcontrib-htmlhelp==2.0.0
sphinxcontrib-jsmath==1.0.1
sphinxcontrib-qthelp==1.0.3
sphinxcontrib-serializinghtml==1.1.5
urllib3==1.26.13
wheel==0.38.4
EOF
RUN pip wheel --wheel-dir=/wheelhouse -c /constraints.txt \
        'pyqt5==5.15.*' 'pyqtwebengine==5.15.*' \
        -r /project/requirements-opt.txt coverage psycopg2-binary \
        -r /project/requirements-core.txt \
        -r /project/requirements-gui.txt
# Build requirements resolved on their own: oldest-supported-numpy pins a numpy below the runtime one.
RUN pip wheel --wheel-dir=/wheelhouse -c /constraints-build.txt \
        'setuptools>=41.0.0,<50.0' wheel cython oldest-supported-numpy \
        sphinx recommonmark

RUN if ls /wheelhouse | grep -iE '^orange3-'; then \
        echo "FAIL: pre-built orange3 wheel in the wheelhouse - the measured build would not compile" >&2; \
        exit 1; \
    fi; \
    echo "GATE 1 OK: no orange3 wheel in the wheelhouse ($(ls /wheelhouse | wc -l) wheels)"

RUN pip install --no-index --find-links=/wheelhouse \
        'pyqt5==5.15.*' 'pyqtwebengine==5.15.*' \
        -r /project/requirements-opt.txt coverage psycopg2-binary
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

# Qt 5.15.2 wheel: the bundled ICU 56 libraries carry no RUNPATH and resolve through libQt5Core's
# $ORIGIN at run time, and the EGLFS platform plugin, never loaded under xvfb, lacks its integration library.
RUN FALTANDO=$(for d in /venv/lib/python3.10/site-packages/PyQt5/Qt5/lib \
                        /venv/lib/python3.10/site-packages/PyQt5/Qt5/plugins/platforms \
                        /venv/lib/python3.10/site-packages/PyQt5/Qt5/libexec \
                        /venv/lib/python3.10/site-packages/PyQt5; do \
        [ -d "$d" ] && find "$d" -maxdepth 1 \( -name '*.so*' -o -name 'QtWebEngineProcess' \) 2>/dev/null; \
      done | grep -v '/plugins/platforms/libqeglfs.so$' \
      | while read -r f; do LD_LIBRARY_PATH=/venv/lib/python3.10/site-packages/PyQt5/Qt5/lib ldd "$f" 2>/dev/null | grep 'not found'; done | sed 's/^[[:space:]]*//' | sort -u); \
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

# OpenSSL 1.1.1 of 20.04 already adds basicConstraints=critical,CA:TRUE from its v3_ca section; a second one
# through -addext duplicates the extension and makes the CA certificate unverifiable.
RUN set -eu; \
    mkdir -p /opt/prebake/tls; \
    openssl req -x509 -newkey rsa:2048 -sha256 -days 36500 -nodes \
        -keyout /opt/prebake/tls/ca.key -out /opt/prebake/tls/ca.crt \
        -subj "/CN=medicao prebake CA" \
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
