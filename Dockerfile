# ##################################### #
#                                       #
#   How-To build this container image   #
#                                       #
# ##################################### #
#
#
# Local build
# -----------
# docker build \
#   -f Dockerfile \
#   --build-arg VERSION=`cat src/VERSION` \
#   --build-arg GIT_BRANCH=`git branch --show-current` \
#   -t safebytelabs-jgonf/gha-docker-demo:`cat src/VERSION` .
#
#
# Platform specific images (when you build for your own platform)
# ---------------------------------------------------------------
# docker build \
#   --build-arg BUILD_DATE=`date -u +"%Y-%m-%d"` \
#   --build-arg VERSION=`cat src/VERSION` \
#   --build-arg GIT_BRANCH=`git branch --show-current` \
#   -t ghcr.io/safebytelabs-jgonf/gha-docker-demo:`cat src/VERSION` .
#
#
# Cross-compile platform independent images (when you use a build facility
# in your platform to cross-compile for another platform)
# ------------------------------------------------------------------------
# docker buildx ls
# docker buildx create --name testbuilder
# docker buildx use testbuilder
# docker buildx inspect --bootstrap
# docker buildx build \
#   --platform linux/amd64 linux/amd64/v2 linux/amd64/v3 \
#              linux/arm64,linux/arm/v7, linux/arm/v6 \
#   --build-arg BUILD_DATE=`date -u +"%Y-%m-%d"` \
#   --build-arg VERSION=`cat src/VERSION` \
#   --build-arg GIT_BRANCH=`git branch --show-current` \
#   -t ghcr.io/safebytelabs-jgonf/gha-docker-demo:`cat src/VERSION` --push .
#
# #############################################################################

FROM python:3.12.2-alpine3.19
LABEL maintainer="Jonathan Gonzalez <jgonf@safebytelabs.com>"
ARG GIT_BRANCH

ENV RUN_DEPENDENCIES="python3 python3-dev py3-pip gcc build-base ensurepip"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1


# Let service stop gracefully
STOPSIGNAL SIGQUIT

RUN apk add --no-cache $RUN_DEPENDENCIES \
    && python3 -m ensurepip              \
    && pip3 install -U pip               \
    && rm -rf /usr/lib/python*/ensurepip \
    && rm -rf /root/.cache               \
    && rm -rf /var/cache/apk/*           \
    && find /                            \
    \( -type d -a -name test -o -name tests \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
    && mkdir /app

# - Copy project files into working directory
COPY ./src/ ./app/
COPY ./requirements.txt ./app/requirements.txt
WORKDIR /app/

# - Install project requirements
RUN pip install --no-cache-dir -r requirements.txt

# - Run the program
CMD [ "python3", "main.py" ]
