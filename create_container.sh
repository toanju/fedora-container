#!/bin/bash

dnf -y install git pykickstart
git clone https://pagure.io/fedora-kickstarts.git

ksflatten --config fedora-kickstarts/fedora-docker-base-minimal.ks -o /test.ks --version F27
sed -i '/^text$/a repo --name=fedora-source  --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-source-27&arch=\$basearch --excludepkgs=fedora-productimg-cloud,fedora-productimg-workstation' /test.ks
sed -i '/^text$/a repo --name=fedora-updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f27&arch=\$basearch --excludepkgs=fedora-productimg-cloud,fedora-productimg-workstation' /test.ks
sed -i '/^text$/a repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-27&arch=\$basearch --excludepkgs=fedora-productimg-cloud,fedora-productimg-workstation' /test.ks
sed -i 's#^text$#url --url=http://dl.fedoraproject.org/pub/fedora/linux/releases/27/Everything/x86_64/os/#' /test.ks

livemedia-creator --ks /test.ks --no-virt --resultdir /results/lmc --make-tar
