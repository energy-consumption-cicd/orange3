
# Runner ubuntu-latest of the tag commit (2025-06-13) is Ubuntu 24.04: the image and the archive of that date.
FROM ubuntu:noble-20250529@sha256:b59d21599a2b151e23eea5f6602f4af4d7d31c4e236d22bf0b62b86d2e386b8f

ARG APT_SNAPSHOT=20250613T112735Z

ENV DEBIAN_FRONTEND=noninteractive

# ca-certificates comes from the current archive only to reach the snapshot service over https.
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    sed -i "s#http://archive.ubuntu.com/ubuntu/#https://snapshot.ubuntu.com/ubuntu/${APT_SNAPSHOT}/#; s#http://security.ubuntu.com/ubuntu/#https://snapshot.ubuntu.com/ubuntu/${APT_SNAPSHOT}/#" \
        /etc/apt/sources.list.d/ubuntu.sources && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# actions/setup-python: the linux-24.04-x64 build of the latest 3.11 patch published before the tag commit; deadsnakes only serves the current one.
ARG PYTHON_VERSION=3.11.13
ARG PYTHON_RELEASE=3.11.13-15433298024
ARG PYTHON_SHA256=bf58712e13464122707e63d8913f17aaeff63293ee4c0cee11ce9f76b188fab6
RUN set -eux; \
    dest=/opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64; \
    mkdir -p "$dest"; \
    curl -fsSL -o /tmp/python.tar.gz \
        "https://github.com/actions/python-versions/releases/download/${PYTHON_RELEASE}/python-${PYTHON_VERSION}-linux-24.04-x64.tar.gz"; \
    echo "${PYTHON_SHA256}  /tmp/python.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/python.tar.gz -C "$dest"; \
    rm -f /tmp/python.tar.gz "$dest/setup.sh"; \
    ln -s "$dest/bin/python3.11" /usr/local/bin/python3.11; \
    python3.11 --version

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

RUN pip install --upgrade pip==25.1.1 setuptools==80.9.0 wheel==0.45.1

COPY --chown=medicao:medicao . /project
WORKDIR /project

RUN cp -a /project/. /src-install/

# The tag pins no versions: what pip resolved against the index as of the tag commit (2025-06-13T11:27:35Z).
COPY <<'EOF' /constraints.txt
alabaster==1.0.0
anyio==4.9.0
anyqt==0.2.1
asttokens==3.0.0
attrs==25.3.0
babel==2.17.0
backports-tarfile==1.2.0
baycomp==1.0.3
bottleneck==1.5.0
cattrs==25.1.1
certifi==2025.4.26
cffi==1.17.1
chardet==5.2.0
charset-normalizer==3.4.2
comm==0.2.2
commonmark==0.9.1
contourpy==1.3.2
coverage==7.9.0
cryptography==45.0.4
cycler==0.12.1
cython==3.1.2
debugpy==1.8.14
decorator==5.2.1
dictdiffer==0.9.0
docutils==0.21.2
et-xmlfile==2.0.0
executing==2.2.0
fonttools==4.58.3
h11==0.16.0
httpcore==1.0.9
httpx==0.28.1
idna==3.10
imagesize==1.4.1
importlib-metadata==8.7.0
ipykernel==6.29.5
ipython==9.3.0
ipython-pygments-lexers==1.1.1
jaraco-classes==3.4.0
jaraco-context==6.0.1
jaraco-functools==4.1.0
jedi==0.19.2
jeepney==0.9.0
jinja2==3.1.6
joblib==1.5.1
jupyter-client==8.6.3
jupyter-core==5.8.1
keyring==25.6.0
keyrings-alt==5.0.2
kiwisolver==1.4.8
libcst==1.8.1
markupsafe==3.0.2
matplotlib==3.10.3
matplotlib-inline==0.1.7
more-itertools==10.7.0
nest-asyncio==1.6.0
networkx==3.5
numpy==2.3.0
openpyxl==3.1.5
opentsne==1.0.2
orange-canvas-core==0.2.6
orange-widget-base==4.26.0
packaging==25.0
pandas==2.3.0
parso==0.8.4
pexpect==4.9.0
pillow==11.2.1
pip==25.1.1
platformdirs==4.3.8
prompt-toolkit==3.0.51
psutil==7.0.0
psycopg2-binary==2.9.10
ptyprocess==0.7.0
pure-eval==0.2.3
pycparser==2.22
pygments==2.19.1
pymssql==2.3.4
pyparsing==3.2.3
pyqt5==5.15.11
pyqt5-qt5==5.15.17
pyqt5-sip==12.17.0
pyqtgraph==0.13.7
pyqtwebengine==5.15.7
pyqtwebengine-qt5==5.15.17
python-dateutil==2.9.0.post0
python-louvain==0.16
pytz==2025.2
pyyaml==6.0.2
pyzmq==26.4.0
qasync==0.27.1
qtconsole==5.6.1
qtpy==2.4.3
recommonmark==0.7.1
requests==2.32.4
requests-cache==1.2.1
roman-numerals-py==3.1.0
scikit-learn==1.7.0
scipy==1.15.3
secretstorage==3.3.3
serverfiles==0.3.1
setuptools==80.9.0
six==1.17.0
sniffio==1.3.1
snowballstemmer==3.0.1
sphinx==8.2.3
sphinxcontrib-applehelp==2.0.0
sphinxcontrib-devhelp==2.0.0
sphinxcontrib-htmlhelp==2.1.0
sphinxcontrib-jsmath==1.0.1
sphinxcontrib-qthelp==2.0.0
sphinxcontrib-serializinghtml==2.0.0
stack-data==0.6.3
threadpoolctl==3.6.0
tornado==6.5.1
traitlets==5.14.3
trubar==0.3.4
truststore==0.10.1
typing-extensions==4.14.0
tzdata==2025.2
url-normalize==2.2.1
urllib3==2.4.0
wcwidth==0.2.13
wheel==0.45.1
xgboost==2.0.3
xlrd==2.0.1
xlsxwriter==3.2.2
zipp==3.23.0
EOF
RUN pip wheel --wheel-dir=/wheelhouse -c /constraints.txt \
        'pyqt5==5.15.*' 'pyqtwebengine==5.15.*' \
        coverage psycopg2-binary pymssql \
        -r /project/requirements-core.txt \
        -r /project/requirements-gui.txt \
        'cython>=3.0' 'numpy>=2.0' recommonmark 'setuptools>=51.0' \
        sphinx wheel 'trubar>=0.3.4'

RUN if ls /wheelhouse | grep -iE '^orange3-'; then \
        echo "FAIL: pre-built orange3 wheel in the wheelhouse - the measured build would not compile" >&2; \
        exit 1; \
    fi; \
    echo "GATE 1 OK: no orange3 wheel in the wheelhouse ($(ls /wheelhouse | wc -l) wheels)"

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
