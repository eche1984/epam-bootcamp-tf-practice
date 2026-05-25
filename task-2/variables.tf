variable "ssh_key" {
  description = "Provides custom public SSH key"
  type        = string
  sensitive   = true
}

variable "project_tag" {
  description = "Project tag value"
  type        = string  
}

variable "id_tag" {
  description = "ID tag value"
  type        = string  
}
