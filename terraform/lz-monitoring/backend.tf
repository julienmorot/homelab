terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/58878934/terraform/state/lz-monitoring"
    lock_address   = "https://gitlab.com/api/v4/projects/58878934/terraform/state/lz-monitoring/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/58878934/terraform/state/lz-monitoring/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }
}
