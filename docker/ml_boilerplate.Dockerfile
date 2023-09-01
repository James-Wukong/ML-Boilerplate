# The python stage is used just to provide a common basis for the poetry and runtime stages.
FROM python:3.12-rc-bullseye as python-base
ARG PROJECT_BASE_DIR="/usr/src/app"
ARG POETRY_VERSION="1.3.2"
ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 

# RUN useradd -m -g root machine-learning
# USER machine-learning
WORKDIR ${PROJECT_BASE_DIR}
# VOLUME . /usr/src/app

# The poetry stage installs Poetry, and uses it to install the Python application 
# and its dependencies in a virtual environment.
FROM python-base as poetry-builder
ENV \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN apt-get update \
    && apt-get install -y curl build-essential vim net-tools git \
    && apt-get install -y --no-install-recommends netcat
RUN python -c 'from urllib.request import urlopen; print(urlopen("https://install.python-poetry.org").read().decode())' | POETRY_VERSION=${POETRY_VERSION} python -
RUN poetry config virtualenvs.create false
# COPY --chown=machine-learning:root ./ml_boilerplate /usr/src/app/ml_boilerplate
COPY ../ml_boilerplate ${PROJECT_BASE_DIR}/ml_boilerplate

WORKDIR ${PROJECT_BASE_DIR}/ml_boilerplate
RUN poetry install --no-interaction --no-ansi --no-dev -vvv

# The runtime stage builds the final Docker Image by copying and configuring 
# the virtual environment from the poetry stage.
# FROM python-base as runtime
# COPY --from=poetry-builder ${PROJECT_BASE_DIR}/ml_boilerplate ${PROJECT_BASE_DIR}/ml_boilerplate
# COPY --from=poetry-builder /opt/poetry /opt/poetry
EXPOSE 8000

# CMD ["flask", "run"]