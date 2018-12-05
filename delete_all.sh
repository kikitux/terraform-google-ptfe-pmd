
mountpoint /var/lib/replicated/snapshots
if [ $? -eq 0 ]; then
  umount /var/lib/replicated/snapshots
fi
  
[ -d /var/lib/replicated/snapshots/ ] && rsync -PavzHl /var/lib/replicated/snapshots/ ~/snap/

systemctl stop replicated replicated-operator replicated-ui
rm -rf /var/lib/replicated /var/lib/replicated-operator /etc/replicated.alias /var/lib/tfe-vault/ /etc/default/replicated-operator /etc/default/replicated 

mkdir -p  /var/lib/replicated/snapshots
mount -a

service docker stop
rm -fr /var/lib/docker

[ -b /dev/nvme0n1 ] && {
  lvm vgremove docker -f
  lvm pvremove /dev/nvme0n1 
}

service docker start

docker ps -a

[ -d ~/snap/ ] && {
  mkdir -p /var/lib/replicated/
  rsync -PavzHl ~/snap/ /var/lib/replicated/snapshots/
}

