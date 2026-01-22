variable "resource_group_name" {
  type        = string
  description = "Resource Group created by my hands in Azure Portal"
  default     = "tfvmex-resources"
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "prefix" {
  type    = string
  default = "tfvmex"
}

variable "admin_username" {
  type    = string
  default = "testadmin"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "VM admin password (set via env var)"
}

variable "vm_size" {
  type    = string
  default = "Standard_DS1_v2"
}
