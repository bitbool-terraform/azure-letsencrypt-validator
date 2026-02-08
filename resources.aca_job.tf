resource "azurerm_container_app_job" "daily_worker" {
  name                         = "daily‐worker‐job"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.ca_env.id

  # Configure the schedule trigger here:
  schedule_trigger_config {
    # Every day at 02:00 (UTC). Adjust to your timezone if needed.
    cron_expression = "0 2 * * *"
    parallelism     = 1
    replica_completion_count = 1
  }

  # Optional: limit retries/timeouts for each replica run
  replica_timeout_in_seconds = 600    # abort if >10 minutes
  replica_retry_limit        = 1      # give up after 1 retry

  template {
    # ---------- Define the shared Azure File volume ----------
    volume {
      name         = "sharedvolume"                              # must match the same name you used in Container App
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.env_storage.name
    }

    # ---------- Define the job container that uses it ----------
    container {
      name   = "worker‐container"
      image  = "mcr.microsoft.com/azuredocs/containerapps‐helloworld:latest" 
      cpu    = 0.25
      memory = "0.5Gi"

      # Mount the same volume under a different path (e.g. /mnt/jobdata)
      volume_mounts {
        name = "sharedvolume"
        path = "/mnt/jobdata"
      }

      # Pass any arguments or env‐vars that your job needs:
      # command = ["python", "process_data.py"]
      # env {
      #   name  = "ENVIRONMENT"
      #   value = "prod"
      # }
    }

    # You can also define init_containers { } if you need pre‐processing
    # or additional volume_mounts inside them, but the pattern is identical.
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_container_app_environment.ca_env,
    azurerm_container_app_environment_storage.env_storage,
  ]
}
