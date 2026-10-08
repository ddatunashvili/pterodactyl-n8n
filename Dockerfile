FROM n8nio/n8n:2.43.2

# Wings runs containers as its system user (default uid 988). Give that uid a
# passwd entry and a home that is the server volume. Written by hand because
# the image is not guaranteed to carry shadow or busybox's adduser.
ARG CONTAINER_UID=988

USER root
# n8n 2.x ships without a package manager or bash, so the entrypoint is POSIX sh.
RUN { grep -q ":${CONTAINER_UID}:" /etc/group || echo "container:x:${CONTAINER_UID}:" >> /etc/group; } \
 && { grep -q ":x:${CONTAINER_UID}:" /etc/passwd || echo "container:x:${CONTAINER_UID}:${CONTAINER_UID}::/home/container:/bin/sh" >> /etc/passwd; } \
 && mkdir -p /home/container && chown ${CONTAINER_UID}:${CONTAINER_UID} /home/container

# Wings drops capabilities from every container, and the kernel refuses to
# exec a binary whose file caps exceed the bounding set. Rewriting each
# executable drops any security.capability xattr; nothing here needs one.
RUN find /usr/local/bin /usr/bin /usr/local/lib/node_modules/n8n/bin -type f -perm -u+x 2>/dev/null | while read -r f; do \
      cp -p "$f" "$f.nocap" && mv -f "$f.nocap" "$f"; \
    done

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

ENV USER=container HOME=/home/container N8N_USER_FOLDER=/home/container \
    N8N_LISTEN_ADDRESS=0.0.0.0 N8N_DIAGNOSTICS_ENABLED=false
USER ${CONTAINER_UID}
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
