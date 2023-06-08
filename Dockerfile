FROM mambaorg/micromamba:1.2.0-bullseye-slim
LABEL org.opencontainers.image.authors="us@couchbits.com"
LABEL org.opencontainers.image.vendor="couchbits GmbH"

# the app
ENV PROJECT_DIR /moveapps-python-sdk
WORKDIR $PROJECT_DIR

USER root
RUN chown -R $MAMBA_USER:$MAMBA_USER $PROJECT_DIR
RUN apt-get update \
    # fix for: `ImportError: libGL.so.1: cannot open shared object file: No such file or directory`
    && apt-get install ffmpeg libsm6 libxext6  -y

USER $MAMBA_USER
COPY --chown=$MAMBA_USER:$MAMBA_USER environment-moveapps.yml ./environment.yml
RUN micromamba install -y -n base -f ./environment.yml && \
    micromamba clean --all --yes

COPY --chown=$MAMBA_USER:$MAMBA_USER sdk.py ./
COPY --chown=$MAMBA_USER:$MAMBA_USER sdk/ ./sdk/
COPY --chown=$MAMBA_USER:$MAMBA_USER resources/ ./resources/
COPY --chown=$MAMBA_USER:$MAMBA_USER tests/ ./tests/
COPY --chown=$MAMBA_USER:$MAMBA_USER app/ ./app/

RUN micromamba run -n base python -m unittest
# this is the working conda env file for the target runtime
RUN cat ./environment.yml
