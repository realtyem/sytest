ARG SYTEST_IMAGE_TAG=buster

FROM matrixdotorg/sytest:${SYTEST_IMAGE_TAG}

ARG PYTHON_VERSION=python3
RUN apt-get -qq update && apt-get -qq install -y \
    ${PYTHON_VERSION} ${PYTHON_VERSION}-dev ${PYTHON_VERSION}-venv eatmydata \
    redis-server

# /src is where we expect Synapse to be
RUN mkdir /src

# Create the virutal env upfront so we don't need to keep reinstall dependencies
# Manually upgrade pip to ensure it can locate Cryptography's binary wheels
RUN ${PYTHON_VERSION} -m venv /venv && /venv/bin/pip install -U pip
RUN /venv/bin/pip install -q --no-cache-dir matrix-synapse[all]

# Uninstall matrix-synapse package so it doesn't collide with the version we try
# and test
RUN /venv/bin/pip uninstall -q --no-cache-dir -y matrix-synapse

# Pre-install test dependencies installed by `scripts/synapse_sytest.sh`.
RUN /venv/bin/pip install -q --no-cache-dir \
        coverage codecov tap.py coverage_enable_subprocess

ENTRYPOINT [ "/bin/bash", "/bootstrap.sh", "synapse" ]
