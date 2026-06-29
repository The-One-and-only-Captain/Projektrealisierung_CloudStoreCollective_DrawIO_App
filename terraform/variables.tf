# ==============================================================================
# SYSTEM VARIABLES (DO NOT TOUCH)
# Diese Variablen werden vom CloudStore Backend injiziert.
# ==============================================================================

variable "deployment_id" {
  description = "Eindeutige ID des Deployments (vom CloudStore Backend gesetzt)"
  type        = string
  validation {
    condition     = length(var.deployment_id) > 0
    error_message = "deployment_id darf nicht leer sein."
  }
}

variable "use_mock_provider" {
  description = "Falls true: kein echter OpenStack-Aufruf (für lokale Tests)"
  type        = bool
  default     = false
}

# ==============================================================================
# APP PARAMETERS
# ==============================================================================

variable "app_name" {
  type        = string
  description = "Name der Drawio-Instanz"
  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.app_name))
    error_message = "app_name: Nur Kleinbuchstaben, Zahlen und Bindestriche erlaubt (3-20 Zeichen)."
  }
}

# Vom Frontend bei one-per-group mitgeschickt — wird hier nicht verwendet
# (DrawIO hat keinen Login), Variable existiert nur damit Terraform die tfvars akzeptiert.
variable "student_groups" {
  type        = map(list(string))
  description = "Projektgruppen (nur bei one-per-group relevant, wird nicht verwendet)"
  default     = {}
}

variable "flavor_name" {
  type        = string
  description = "OpenStack Flavor (VM-Größe)"
  default     = "gp1.small"
  validation {
    condition     = contains(["gp1.small", "gp1.medium"], var.flavor_name)
    error_message = "flavor_name: Muss 'gp1.small' oder 'gp1.medium' sein."
  }
}

# ==============================================================================
# INFRASTRUCTURE DEFAULTS (werden vom CloudStore gesetzt)
# ==============================================================================

variable "image_name" {
  type    = string
  default = "Ubuntu 22.04"
}

variable "network_name" {
  type    = string
  default = "NAT"
}

variable "external_network_name" {
  type    = string
  default = "DHBW"
}

variable "floating_ip_pool" {
  type    = string
  default = "DHBW"
}
