# Auto-generated via Ansible: edit src/Dockerfiles/base/Dockerfile.j2 instead.

FROM wayofdev/ansible:builder-alpine-latest as builder

FROM alpine:edge as production

# Labels
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL "maintainer"="lotyp <lotyp7@gmail.com>"
LABEL "vendor"="wayofdev"
LABEL "org.opencontainers.image.authors"="lotyp <lotyp7@gmail.com>"
LABEL "org.opencontainers.image.url"="https://hub.docker.com/r/wayofdev/ansible-base"
LABEL "org.opencontainers.image.documentation"="https://github.com/wayofdev/docker-ansible"
LABEL "org.opencontainers.image.source"="https://github.com/wayofdev/docker-ansible"
LABEL "org.opencontainers.image.vendor"="wayofdev"
LABEL "org.opencontainers.image.licenses"="MIT"
LABEL "org.opencontainers.image.ref.name"="ansible-base"
LABEL "org.opencontainers.image.title"="ansible-base"
LABEL "org.opencontainers.image.description"="ansible-base"

ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

# Define uid/gid and user/group names
ENV MY_USER="ansible"
ENV MY_GROUP="ansible"
ENV MY_UID=1000
ENV MY_GID=1000

RUN set -eux; \
    apk -U upgrade -a \
    && apk add --no-cache \
        # libgcc required for ansible-vault
		libgcc \
		py3-pip \
		python3 \
        yaml \
    # Extra Tools
    && apk add --no-cache \
        curl \
        git \
        bash \
        jq \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    # Clean up some space
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=builder /usr/lib/python3.10/site-packages/ /usr/lib/python3.10/site-packages/
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection
COPY ./configs/docker-entrypoint.sh /docker-entrypoint.sh

RUN set -eux \
	# Create user, group and home dir
	&& addgroup -g ${MY_GID} ${MY_GROUP} \
	&& adduser -h /home/${MY_USER} -s /bin/bash -G ${MY_GROUP} -D -u ${MY_UID} ${MY_USER} \
    # Pre-compile Python for better performance
	&& python3 -m compileall /usr/lib/python3.10 \
	&& chmod +x /docker-entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
