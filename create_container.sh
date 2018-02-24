#!/bin/bash

set -e

FV=27
TMPDIR=$(mktemp -d)
NAME=lorax

#chcon -Rt svirt_sandbox_file_t ${TMPDIR}

docker run --privileged -v "${TMPDIR}":/workdir -dti --name ${NAME} --rm toanju/lorax:27 /bin/bash
docker exec -i ${NAME} /bin/bash <<EOF
git clone -b f${FV} https://pagure.io/fedora-kickstarts.git /workdir/fedora-kickstarts
ksflatten --config /workdir/fedora-kickstarts/fedora-docker-base-minimal.ks --version F${FV} -o /workdir/flat.ks
sed -i '/^text$/a repo --name=fedora-source  --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-source-${FV}&arch=\$basearch --excludepkgs=fedora-productimg-cloud,fedora-productimg-workstation' /workdir/flat.ks
sed -i '/^text$/a repo --name=fedora-updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f${FV}&arch=\$basearch --excludepkgs=fedora-productimg-cloud,fedora-productimg-workstation' /workdir/flat.ks
sed -i '/^text$/a repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-${FV}&arch=\$basearch --excludepkgs=fedora-productimg-cloud,fedora-productimg-workstation' /workdir/flat.ks
sed -i '/^text$/a url --url=http://dl.fedoraproject.org/pub/fedora/linux/releases/${FV}/Everything/x86\_64/os/' /workdir/flat.ks
sed -i '/^text$/d' /workdir/flat.ks
livemedia-creator --make-tar --no-virt --ks /workdir/flat.ks --resultdir /workdir/tmp --image-name fedora-root.tar.xz
EOF

cp ${TMPDIR}/tmp/fedora-root.tar.xz .

# clean up
docker exec -i ${NAME} /bin/bash <<EOF
rm -rf /workdir/{anaconda,fedora-kickstarts,tmp}
EOF

docker stop ${NAME}
rm -rf ${TMPDIR}
