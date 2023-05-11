terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url  = "https://${var.PM_ADDR}:${var.PM_PORT}/api2/json"
  pm_tls_insecure = true
  
  pm_api_token_id       = var.PM_API_TOKEN_ID
  pm_api_token_secret   = var.PM_API_TOKEN_SECRET
  # pm_user     = var.PM_USER
  # pm_password = var.PM_PASS

  # Logging (for development only)
  # pm_log_enable = true
  # pm_log_file   = "terraform-plugin-proxmox.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}
