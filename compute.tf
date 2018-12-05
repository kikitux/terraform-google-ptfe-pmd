variable compute_name {
  description = "Compute VM name"
}

variable disk_size_compute_boot {
  description = "The size of data disk, in GB."
}

variable disk_size_compute_snapshot {
  description = "The size of data disk, in GB."
}

variable disk_size_compute_mount {
  description = "The size of data disk, in GB."
}

variable "region" {}

variable "zone" {}

variable "project" {}

resource "google_compute_disk" "compute_disk_snap" {
  name = "${var.compute_name}-snap"
  type = "pd-ssd"
  size = "${var.disk_size_compute_snapshot}"
  zone = "${var.zone}"

  labels {}
}

resource "google_compute_disk" "compute_disk_mount" {
  name = "${var.compute_name}-mount"
  type = "pd-ssd"
  size = "${var.disk_size_compute_mount}"
  zone = "${var.zone}"

  labels {}
}

resource "google_compute_instance" "compute" {
  name         = "${var.compute_name}"
  machine_type = "n1-standard-4"
  zone         = "${var.zone}"

  lifecycle {
    ignore_changes = [
      "boot_disk.initialize_params.image",
    ]
  }

  boot_disk {
    initialize_params {
      type  = "pd-ssd"
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
      size  = "${var.disk_size_compute_boot}"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  attached_disk {
    source      = "${google_compute_disk.compute_disk_snap.self_link}"
    device_name = "${var.compute_name}-snap"
  }

  attached_disk {
    source      = "${google_compute_disk.compute_disk_mount.self_link}"
    device_name = "${var.compute_name}-mount"
  }

  network_interface {
    network       = "default"
    access_config = {}
  }


 # copy automated-recovery.sh
  provisioner "file" {
    source      = "automated-recovery.sh"
    destination = "/root/automated-recovery.sh"
  }

  # copy delete_all.sh
  provisioner "file" {
    source      = "delete_all.sh"
    destination = "/root/delete_all.sh"
  }

  metadata_startup_script = <<SCRIPT
echo processing metadata_startup_script

# installing lang pack
apt-get update
apt-get dist-upgrade -y                               # update OS
apt-get install -y thin-provisioning-tools            # for docker devicemapper
apt-get install -y language-pack-en sysstat vim htop  # some nice tools

# container top
wget https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64 -O /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

# install the Stackdriver monitoring agent:
curl -sS https://dl.google.com/cloudagents/install-monitoring-agent.sh | bash

# install the Stackdriver logging agent:
curl -sS https://dl.google.com/cloudagents/install-logging-agent.sh | bash

# docker conf mtu 1460
mkdir -p /etc/docker/
cat > /etc/docker/daemon.json <<EOF
{
  "mtu": 1460
}
EOF

# configure docker images disk
echo "looking for snap disk ${var.compute_name}-snap"
while [ ! -b /dev/nvme0n1 ] ; do
  echo -n .
  sleep 2
done

blkid /dev/nvme0n1 || mkfs /dev/nvme0n1
grep /dev/nvme0n1 /etc/fstab || {
  echo "/dev/nvme0n1 /var/lib/docker auto defaults 0 0" | tee -a /etc/fstab
}
mkdir -p /var/lib/docker
mount -a

# configure snap disk
echo "looking for snap disk ${var.compute_name}-snap"
while [ ! -b /dev/disk/by-id/google-${var.compute_name}-snap ] ; do 
  echo -n .
  sleep 2
done

blkid /dev/disk/by-id/google-${var.compute_name}-snap || mkfs /dev/disk/by-id/google-${var.compute_name}-snap
grep /dev/disk/by-id/google-${var.compute_name}-snap /etc/fstab || {
  echo "/dev/disk/by-id/google-${var.compute_name}-snap /var/lib/replicated/snapshots auto defaults 0 0" | tee -a /etc/fstab 
}
mkdir -p /var/lib/replicated/snapshots
mount -a

# configure mount disk
echo "looking for mount disk ${var.compute_name}-mount"
while [ ! -b /dev/disk/by-id/google-${var.compute_name}-mount ] ; do
  echo -n .
  sleep 2
done

blkid /dev/disk/by-id/google-${var.compute_name}-mount || mkfs /dev/disk/by-id/google-${var.compute_name}-mount
grep /dev/disk/by-id/google-${var.compute_name}-mount /etc/fstab || {
  echo "/dev/disk/by-id/google-${var.compute_name}-mount /media/mount auto defaults 0 0" | tee -a /etc/fstab
}
mkdir -p /media/mount
mount -a

# create ptfe.sh
cat > /root/ptfe.sh <<EOF
curl https://install.terraform.io/ptfe/stable | sudo bash
EOF

# certbot
cat > /root/certbot.sh <<EOF
which certbot || {
  apt-get update
  apt-get install -y software-properties-common
  add-apt-repository -y ppa:certbot/certbot
  apt-get update
  apt-get install -y certbot 
}

echo "now run:"
echo "sudo certbot certonly --standalone -d ${var.compute_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"

echo "certs will be in:"
echo "/etc/letsencrypt/live/"

echo "type:"
echo "find /etc/letsencrypt/live/*/{privkey.pem,fullchain.pem}"

echo "later, to renew the certificates you can run:"
echo "sudo certbot renew"

EOF

SCRIPT
}

resource "google_dns_record_set" "dns_compute" {
  name = "${var.compute_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"

  rrdatas = ["${google_compute_instance.compute.network_interface.0.access_config.0.nat_ip}"]
}

output "compute_instance_address" {
  value = "${var.compute_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"
}

output "compute_instance_ip" {
  value = "${google_compute_instance.compute.network_interface.0.access_config.0.nat_ip}"
}

output "stackdriver_compute" {
  value = "https://app.google.stackdriver.com/instances/${google_compute_instance.compute.instance_id}?project=alvaro-space"
}
