variable "resource_group_name" {
  type        = string
  description = "Resource Group created manually in Azure Portal"
  default     = "tfvmex-resources"
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

variable "local_default_page" {
  type        = string
  description = "Path to custom HTML page for Nginx"
  default     = "./index.html"
}
