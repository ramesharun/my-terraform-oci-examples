# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# --------- Get the OCID for the more recent for Oracle Linux 7.x disk image
data "oci_core_images" "ImageOCID-ol7" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.8"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.8-[^G].*$"]
    regex  = true
  }
}

