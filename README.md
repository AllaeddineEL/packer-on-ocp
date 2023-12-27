# packer-on-ocp

curl -O -L https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2

LIBGUESTFS_BACKEND=direct virt-customize --format qcow2 -a CentOS-7-x86_64-GenericCloud.qcow2 --root-password password:s0m3password