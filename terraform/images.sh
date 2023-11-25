#!/bin/bash

openstack image show talos-v1.5.5 > /dev/null || (
    # download
    curl -L -o talos.xz  https://github.com/siderolabs/talos/releases/download/v1.5.5/openstack-amd64.raw.xz

    # unzip
    # brew install p7zip
    7z x talos.xz
    rm talos.xz

    # upload
    openstack image create --progress --disk-format raw --file talos talos-v1.5.5
    rm talos
)

openstack image show talos-v1.4.8 > /dev/null || (
    # download
    curl -L -o talos.tgz https://github.com/siderolabs/talos/releases/download/v1.4.8/openstack-amd64.tar.gz

    # tar
    tar xf talos.tgz
    rm talos.tgz

    # upload
    openstack image create --progress --disk-format raw --file disk.raw talos-v1.4.8
    rm disk.raw
)
