terraform {
  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source  = "hashicorp/azurerm"
      version = ">= 3.7.1" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    }
  }
}