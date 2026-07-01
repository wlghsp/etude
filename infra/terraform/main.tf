terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# VCN
resource "oci_core_vcn" "etude" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "etude-vcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "etude" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.etude.id
  display_name   = "etude-igw"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "etude" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.etude.id
  display_name   = "etude-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.etude.id
  }
}

# Security List (방화벽)
resource "oci_core_security_list" "etude" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.etude.id
  display_name   = "etude-sl"

  # SSH
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # 아웃바운드 전체 허용
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Subnet
resource "oci_core_subnet" "etude" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.etude.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "etude-subnet"
  route_table_id    = oci_core_route_table.etude.id
  security_list_ids = [oci_core_security_list.etude.id]
}

# ARM VM (Always Free)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Ubuntu 22.04 ARM64 최신 이미지 자동 조회 (리전마다 OCID가 다르므로 하드코딩하지 않음)
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "etude" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "etude-server"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.etude.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# Reserved Public IP (고정 IP)
resource "oci_core_public_ip" "etude" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "etude-ip"
  private_ip_id  = data.oci_core_private_ips.etude.private_ips[0].id
}

data "oci_core_private_ips" "etude" {
  subnet_id  = oci_core_subnet.etude.id
  ip_address = oci_core_instance.etude.private_ip
}