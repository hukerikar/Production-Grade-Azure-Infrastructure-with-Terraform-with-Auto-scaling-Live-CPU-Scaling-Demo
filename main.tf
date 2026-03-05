

#=============================================== Resource group ============================================
resource "azurerm_resource_group" "example" {
  name     = "${var.environment}-rg"
  location = var.location
}
#======================================Virtual network -> subnet =======================================
resource "azurerm_virtual_network" "example" {
  name                = "${var.environment}-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

#=========================================== Public IP of LB =================================================
resource "azurerm_public_ip" "example" {
  name                = "${var.environment}-pip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku = "Standard"
}
#=========================================== Load Balancer ================================================


resource "azurerm_lb" "example" {
  name                = "${var.environment}-LB"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

#=====================================AutoScale setting (scale up and down) ===============================

resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.example.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT3M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 1 #useally 75 %
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 1
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  predictive {
    scale_mode      = "Enabled"
    look_ahead_time = "PT5M"
  }

  notification {
    email {
      custom_emails = ["srujanhukerikar21@gmail.com"]
          }
  }
}
#======================= tagging subnet & nsg together and forming assocation================

resource "azurerm_subnet_network_security_group_association" "name" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.example.id

  depends_on = [
    azurerm_subnet.internal,
    azurerm_network_security_group.example
  ]
}

  
#======================================= NSG ===============================================
resource "azurerm_network_security_group" "example" {
  name                = "${var.environment}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
      
 dynamic "security_rule"{ 
    for_each = local.inbound_rules

 
    content {
      name                       = "Allow-${security_rule.key}"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
 
  tags = {
    environment = var.environment
  }
}
#==========================================Linux VMSS =======================================
resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "${var.environment}-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard_D2s_v3"
  instances           = 1
  admin_username      = "adminuser"


    


admin_ssh_key {
  username   = "adminuser"
  public_key = file("azure_key.pub")
}


disable_password_authentication = true

custom_data = base64encode(file("user-data.sh"))

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
   
  network_interface {
    name    = "example"
    primary = true  
    
    ip_configuration {
      
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]
    }
  }
  lifecycle {
    ignore_changes = [instances]
  }
  
}
#=====================================backend bool address =======================================

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}
resource "azurerm_lb_probe" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "http-probe"
  port            = 80
  protocol        = "Tcp"
}
resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.example.id
  disable_outbound_snat = true

}

resource "azurerm_lb_outbound_rule" "example" {
  name                    = "outbound-rule"
  loadbalancer_id         = azurerm_lb.example.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}





