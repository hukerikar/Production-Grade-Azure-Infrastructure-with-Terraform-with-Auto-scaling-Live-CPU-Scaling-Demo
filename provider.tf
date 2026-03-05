terraform {
  required_providers {
    azurerm ={
        source = "hashicorp/azurerm"
        version = "=4.6.0"
    }

  }
  required_version = ">=1.14.4"
}

provider "azurerm" {
    subscription_id = "9dc50af1-f67d-44f2-8d02-79fe0f028e7d"

    features{}
  
}
