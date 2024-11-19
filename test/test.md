# https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/ISO/x86_64/openEuler-24.03-LTS-x86_64-dvd.iso
virt-install \
    --connect qemu:///system \
    --name openeuler2403 \
    --memory 8192 \
    --vcpus 4 \
    --cpu host-passthrough \
    --disk path=/data/libvirt/images/openeuler2403.qcow2,size=100 \
    --cdrom /data/libvirt/images/openEuler-24.03-LTS-x86_64-dvd.iso \
    --os-variant linux2022 \
    --network network=default \
    --graphics vnc,port=15902,password=test \
    --boot cdrom,hd \
    --noautoconsole

创建快照和镜像

    virsh --connect qemu:///system snapshot-create-as openeuler2403 --name "init" --description "init"
    virsh --connect qemu:///system snapshot-list openeuler2403
    virsh --connect qemu:///system start openeuler2403
    virsh --connect qemu:///system snapshot-delete openeuler2403 --snapshotname init
    virsh --connect qemu:///system domblklist openeuler2403

恢复快照
    virsh --connect qemu:///system snapshot-revert openeuler2403 --snapshotname init
