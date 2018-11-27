variable compute_name {
  description = "Compute VM name"
  default     = "ptfe-pmd"
}

variable disk_size_compute_boot {
  description = "The size of data disk, in GB."
  default     = 60
}

variable disk_size_compute_snapshot {
  description = "The size of data disk, in GB."
  default     = 200
}

variable disk_size_compute_mount {
  description = "The size of data disk, in GB."
  default     = 200
}

variable dns_zone {
  description = "dns_zone"
  default     = "gcp"
}

variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "europe-west4-a"
}

variable "project" {
  default = "alvaro-space"
}

provider "google" {
  credentials = "${file("gcp.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

module "google-ptfe-pmd" {
  source                     = "github.com/kikitux/terraform-google-ptfe-pmd"
  disk_size_compute_mount    = "${var.disk_size_compute_mount}"
  zone                       = "${var.zone}"
  project                    = "${var.project}"
  disk_size_compute_boot     = "${var.disk_size_compute_boot}"
  disk_size_compute_snapshot = "${var.disk_size_compute_snapshot}"
  region                     = "${var.region}"
  compute_name               = "${var.compute_name}"
  dns_zone                   = "${var.dns_zone}"
}

output "compute_instance_address" {
  value = "${module.google-ptfe-pmd.compute_instance_address}"
}

output "compute_instance_ip" {
  value = "${module.google-ptfe-pmd.compute_instance_ip}"
}

output "stackdriver_compute" {
  value = "${module.google-ptfe-pmd.stackdriver_compute}"
}
