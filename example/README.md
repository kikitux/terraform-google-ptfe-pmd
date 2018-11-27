# Example

## Pre-Requirements

- google cloud account
- project created
- a dns zone within the project
- a service account, space admin in json format, `gcp.json`

## How to use

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

