data "azurerm_container_registry" "jmeter_acr" {
  name                = var.JMETER_ACR_NAME
  resource_group_name = var.JMETER_ACR_RESOURCE_GROUP_NAME
}

resource "random_id" "random" {
  byte_length = 4
}

resource "azurerm_network_profile" "jmeter_net_profile" {
  name                = "${var.PREFIX}netprofile"
  location            = data.azurerm_resource_group.azurerm_resource_group_vnet.location
  resource_group_name = data.azurerm_resource_group.azurerm_resource_group_vnet.name

  container_network_interface {
    name = "${var.PREFIX}cnic"

    ip_configuration {
      name      = "${var.PREFIX}ipconfig"
      subnet_id = data.azurerm_subnet.subnet_devops_pool.id
    }
  }
}

resource "azurerm_storage_account" "jmeter_storage" {
  name                =  "${var.PREFIX}storage${random_id.random.hex}"
  resource_group_name = data.azurerm_resource_group.azurerm_resource_group_vnet.name
  location            = data.azurerm_resource_group.azurerm_resource_group_vnet.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = ["${data.azurerm_subnet.subnet_devops_pool.id}"]
  }
}

resource "azurerm_storage_share" "jmeter_share" {
  name                 = "jmeter"
  storage_account_name = azurerm_storage_account.jmeter_storage.name
  quota                = var.JMETER_STORAGE_QUOTA_GIGABYTES
}

resource "azurerm_container_group" "jmeter_workers" {
  count               = var.JMETER_WORKERS_COUNT
  name                = "${var.PREFIX}-worker${count.index}"
  location            = data.azurerm_resource_group.azurerm_resource_group_vnet.location
  resource_group_name = data.azurerm_resource_group.azurerm_resource_group_vnet.name

  ip_address_type = "Private"
  os_type         = "Linux"
  restart_policy      = "Never"

  network_profile_id = "/subscriptions/cf776652-65ca-4652-9d95-cfb47031d510/resourceGroups/AZ-CUS-RG-PREPROD-VCLOUD-NET/providers/Microsoft.Network/networkProfiles/jmeternetprofile"
  #network_profile_id = azurerm_network_profile.jmeter_net_profile.id


  image_registry_credential {
    server   = data.azurerm_container_registry.jmeter_acr.login_server
    username = data.azurerm_container_registry.jmeter_acr.admin_username
    password = data.azurerm_container_registry.jmeter_acr.admin_password
  }

  container {
    name   = "jmeter"
    image  = var.JMETER_DOCKER_IMAGE
    cpu    = var.JMETER_WORKER_CPU
    memory = var.JMETER_WORKER_MEMORY

    ports {
      port     = var.JMETER_DOCKER_PORT
      protocol = "TCP"
    }

    volume {
      name                 = "jmeter"
      mount_path           = "/jmeter"
      read_only            = true
      storage_account_name = azurerm_storage_account.jmeter_storage.name
      storage_account_key  = azurerm_storage_account.jmeter_storage.primary_access_key
      share_name           = azurerm_storage_share.jmeter_share.name
    }

    commands = [
      "/bin/sh",
      "-c",
      #"cp -r /jmeter/* .; /entrypoint.sh -s -J server.rmi.ssl.disable=true",
      "cp -r /jmeter/* .; /entrypoint.sh -s -Djava.rmi.server.hostname=$(ifconfig eth0 | grep 'inet addr:' | awk '{gsub(\"addr:\", \"\"); print $2}') -J server.rmi.ssl.disable=true",
    ]
  }
}

resource "azurerm_container_group" "jmeter_controller" {
  name                = "${var.PREFIX}-controller"
  location            = data.azurerm_resource_group.azurerm_resource_group_vnet.location
  resource_group_name = data.azurerm_resource_group.azurerm_resource_group_vnet.name

  ip_address_type = "Private"
  os_type         = "Linux"


  network_profile_id = "/subscriptions/cf776652-65ca-4652-9d95-cfb47031d510/resourceGroups/AZ-CUS-RG-PREPROD-VCLOUD-NET/providers/Microsoft.Network/networkProfiles/jmeternetprofile"
  #network_profile_id = azurerm_network_profile.jmeter_net_profile.id


  restart_policy = "Never"

  image_registry_credential {
    server   = data.azurerm_container_registry.jmeter_acr.login_server
    username = data.azurerm_container_registry.jmeter_acr.admin_username
    password = data.azurerm_container_registry.jmeter_acr.admin_password
  }

  container {
    name   = "jmeter"
    image  = var.JMETER_DOCKER_IMAGE
    cpu    = var.JMETER_CONTROLLER_CPU
    memory = var.JMETER_CONTROLLER_MEMORY

    ports {
      port     = var.JMETER_DOCKER_PORT
      protocol = "TCP"
    }

    volume {
      name                 = "jmeter"
      mount_path           = "/jmeter"
      read_only            = false
      storage_account_name = azurerm_storage_account.jmeter_storage.name
      storage_account_key  = azurerm_storage_account.jmeter_storage.primary_access_key
      share_name           = azurerm_storage_share.jmeter_share.name
    }

    commands = [
      "/bin/sh",
      "-c",
      #"cp -r /jmeter/*",
      "cp -r /jmeter/* | cd /jmeter; /entrypoint.sh -n -s  -J server.rmi.ssl.disable=true  -Djava.rmi.server.hostname=$(ifconfig eth0 | grep 'inet addr:' | awk '{gsub(\"addr:\", \"\"); print $2}') -t ${var.JMETER_JMX_FILE} -l ${var.JMETER_RESULTS_FILE} -e -o ${var.JMETER_DASHBOARD_FOLDER} -R ${join(",", "${azurerm_container_group.jmeter_workers.*.ip_address}")} ${var.JMETER_EXTRA_CLI_ARGUMENTS}",
      #"cd /jmeter; /entrypoint.sh -n -s  -J server.rmi.ssl.disable=true  -Djava.rmi.server.hostname=$(ifconfig eth0 | grep 'inet addr:' | awk '{gsub(\"addr:\", \"\"); print $2}') -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.samplerData=true -Jjmeter.save.saveservice.requestHeaders=true -Jjmeter.save.saveservice.url=true -Jjmeter.save.saveservice.responseHeaders=true -t ${var.JMETER_JMX_FILE} -l ${var.JMETER_RESULTS_FILE} -e -o ${var.JMETER_DASHBOARD_FOLDER} -R ${join(",", "${azurerm_container_group.jmeter_workers.*.ip_address}")} ${var.JMETER_EXTRA_CLI_ARGUMENTS}",
    
    ]
  }
}
