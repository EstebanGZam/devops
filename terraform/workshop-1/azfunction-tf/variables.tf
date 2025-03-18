variable "subscription_id" {
  description = "The subscription ID to use for Azure resources."
  type        = string
}

variable "name_function" {
  type        = string
  description = "Name Function"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Location"
}