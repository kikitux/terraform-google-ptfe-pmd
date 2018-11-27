# Example

This is a sample code that uses the terraform-google-tfe-pmd module.

In order to this to work, you need to have a google key in this directory.

```
gcp.json
```

That need to be workspace admin.

From there review `main.tf` and adjust variables to suit.

```
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
```


