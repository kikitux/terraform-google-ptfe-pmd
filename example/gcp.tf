provider "google" {
  credentials = "${file("gcp.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}
