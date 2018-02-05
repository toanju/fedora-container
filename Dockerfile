FROM scratch
LABEL maintainer "Tobias Jungel <tobias.jungel@gmail.com>"
ENV container=oci
ADD ./lmc/root.tar.xz /
