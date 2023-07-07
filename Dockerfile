FROM alpine:3.14

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="helm-kubectl-jq" \
    org.label-schema.url="https://hub.docker.com/r/ilanni2460/helm-kubectl-jq/" \
    org.label-schema.vcs-url="https://github.com/ilanni2460/docker-helm-kubectl-jq" \
    org.label-schema.build-date=$BUILD_DATE

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_LATEST_VERSION="v1.19.4"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.3.4"

RUN set -xe \
    &&  echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    &&  echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    &&  echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --allow-untrusted --no-cache bash coreutils ca-certificates curl git git-lfs gnupg musl-locales musl-locales-lang tini ttf-dejavu tzdata unzip jq busybox-extras lrzsz openssh-client wget\
    && ln -s /usr/bin/lrz /usr/bin/rz \
    && ln -s /usr/bin/lsz /usr/bin/sz \
    && chmod u+s /bin/busybox \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm


WORKDIR /config

CMD bash
