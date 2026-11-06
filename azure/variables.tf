variable "rg_name" {
  type        = string
  description = "Azure Resource Group Name"
  sensitive   = true
}

variable "google_sheet_csv_url" {
  type = string 
  description = "Google Sheet CSV URL"
  sensitive = true
}