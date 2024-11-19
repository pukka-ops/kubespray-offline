#!/bin/bash
# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.26.0}
#KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-master}

# These version must be same as kubespray.
# Refer `roles/kubespray-defaults/defaults/main/download.yml` of kubespray.
RUNC_VERSION=1.1.13
CONTAINERD_VERSION=1.7.21
NERDCTL_VERSION=1.7.6
CNI_VERSION=1.4.0

# container registry port
REGISTRY_PORT=${REGISTRY_PORT:-35000}

# Install python from source
PYTHON_VERSION=3.12.7
