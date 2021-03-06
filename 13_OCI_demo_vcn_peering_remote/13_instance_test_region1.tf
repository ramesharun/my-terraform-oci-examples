# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data "oci_core_images" "OLImageOCID-ol7-r1" {
  provider                 = oci.r1
  compartment_id           = var.r1_compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.7"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.7-[^G].*$"]
    regex  = true
  }
}

# ------ Create a test compute instance (Oracle Linux 7) in region 1
resource "oci_core_instance" "tf-demo13-r1" {
  provider            = oci.r1
  availability_domain = data.oci_identity_availability_domains.r1ADs.availability_domains[var.r1_AD - 1]["name"]
  compartment_id      = var.r1_compartment_ocid
  display_name        = "tf-demo13-r1"
  shape               = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.OLImageOCID-ol7-r1.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.r1-pubnet.id
    hostname_label = "demo13reg1"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
  }
}

output "Instance_VCN1_REGION1" {
  value = <<EOF


  ---- You can SSH to the instance in VCN1/REGION1 by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo13-r1.public_ip}

  ---- You can then ping instance in VCN2/REGION2 using private IP address
  ping ${oci_core_instance.tf-demo13-r2.private_ip}

EOF
}