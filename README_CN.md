# Kubespray 离线文件生成脚本

## 这是啥？

这些是用于 [Kubespray 离线环境](https://kubespray.io/#/docs/offline-environment) 的离线支持脚本。

支持以下内容：

* 下载离线文件。
  * 下载用于操作系统包的 Yum/Deb 仓库文件。
  * 下载 Kubespray 使用的所有容器镜像。
  * 下载 Kubespray 的 PyPI 镜像文件。
* 目标节点支持脚本。
  * 从本地文件安装 containerd。
  * 启动 nginx 容器作为 web 服务器，提供 Yum/Deb 仓库和 PyPI 镜像。
  * 启动 Docker 私有仓库。
  * 加载所有容器镜像并推送到私有仓库。

## 需求

* RHEL / AlmaLinux / Rocky Linux : 8 / 9
* Ubuntu 20.04 / 22.04 / 24.04
* openEuler 22.03 / 24.03
* KylinOS V10 SP3

## 下载离线文件

注意：必须在与 k8s 目标节点相同的操作系统上执行此过程。

在下载离线文件之前，检查并编辑 `config.sh` 中的配置。

`podman` 会自动安装以拉取和保存容器镜像。
但你可以使用 `containerd` 代替 `podman`。

* 使用 containerd
  * 运行 `install-containerd.sh` 安装 containerd 和 nerdctl。
  * 编辑 `config.sh`，将 `docker` 变量改为 nerdctl。

然后，下载所有文件：

```bash
./download-all.sh
```

所有工件将存储在 `./outputs` 目录中。

该脚本调用以下所有脚本：

* prepare-pkgs.sh
  * 设置 python、podman 等。
* prepare-py.sh
  * 设置 python 虚拟环境，安装所需的 python 包。
* get-kubespray.sh
  * 如果不存在 KUBESPRAY_DIR，下载并解压 kubespray。
* pypi-mirror.sh
  * 下载 PyPI 镜像文件。
* download-kubespray-files.sh
  * 下载 kubespray 离线文件（容器、文件等）。
* download-additional-containers.sh
  * 下载额外的容器。
  * 你可以将任何容器镜像的 repoTag 添加到 imagelists/*.txt。
* create-repo.sh
  * 下载 RPM 或 DEB 仓库。
* copy-target-scripts.sh
  * 复制目标节点脚本。

## 目标节点支持脚本

将 `outputs` 目录中的所有内容复制到目标节点（运行 ansible 的节点）。
然后在 `outputs` 目录中运行以下脚本。

* setup-container.sh
  * 从本地文件安装 containerd。
  * 将 nginx 和 registry 镜像加载到 containerd。
* start-nginx.sh
  * 启动 nginx 容器。
* setup-offline.sh
  * 设置 yum/deb 仓库配置和 PyPI 镜像配置以使用本地 nginx 服务器。
* setup-py.sh
  * 从本地仓库安装 python3 和虚拟环境。
* start-registry.sh
  * 启动 Docker 私有仓库容器。
* load-push-images.sh
  * 将所有容器镜像加载到 containerd。
  * 标记并推送它们到私有仓库。
* extract-kubespray.sh
  * 解压 kubespray 压缩包并应用所有补丁。

你可以在 `config.sh` 中配置 nginx 和私有仓库的端口号。

## 使用 Kubespray 部署 Kubernetes

### 安装所需包

创建并激活虚拟环境：

```bash
# 示例
$ python3.11 -m venv ~/.venv/3.11
$ source ~/.venv/3.11/bin/activate
$ python --version # 检查 python 版本
```

解压 kubespray 并应用补丁：

```bash
./extract-kubespray.sh
cd kubespray-{version}
```

安装 ansible：

```bash
pip install -U pip # 更新 pip
pip install -r requirements.txt # 安装 ansible
```

### 创建 offline.yml

将 [offline.yml](./offline.yml) 文件复制到你的库存目录的 `group_vars/all/offline.yml`，并进行编辑。

你需要将 `YOUR_HOST` 更改为你的仓库/nginx 主机 IP。

注意：

* `runc_donwload_url` 与 kubespray 官方文档不同，必须包含 `runc_version`。
* 从 kubespray 2.23.0 开始，containerd 的不安全仓库配置已更改。你需要设置 `containerd_registries_mirrors` 代替 `containerd_insecure_registries`。

### 部署离线仓库配置

使用 ansible 将使用你的 yum_repo/ubuntu_repo 的离线仓库配置部署到所有目标节点。

首先，将离线设置的 playbook 复制到 kubespray 目录。

```bash
cp -r ${outputs_dir}/playbook ${kubespray_dir}
```

然后执行 `offline-repo.yml` playbook。

```bash
cd ${kubespray_dir}
ansible-playbook -i ${your_inventory_file} offline-repo.yml
```

### 运行 Kubespray

运行 kubespray ansible playbook。

```bash
# 示例
$ ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml
```
