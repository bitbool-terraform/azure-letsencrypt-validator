module "azure-container-app" {
    source = "git::https://github.com/bitbool-terraform/azure-container-app.git?ref=v1.0.1"
    # source = "../../bitbool-terraform/azure-container-app"

    location = var.letencrypt_validator.location
    resource_group = var.letencrypt_validator.resource_group

    container_app_environment_id = var.letencrypt_validator.aca_env_id

    app_name = lower(format("%s-nginx",var.letencrypt_validator.name))
    app_image = lookup(var.letencrypt_validator,"nginx_image", "nginx:latest")
    app_env = each.value.env

    app_ingress_enabled = each.value.ingress_enabled

    identities = each.value.identities

    workload_profile = each.value.workload_profile

    app_gw = lookup(each.value,"app_gw",{})

    secrets = local.secretSets_combined
    app_secrets = each.value.secrets
    registry = lookup(each.value,"registry",null)
    target_port = each.value.target_port
    tags        = each.value.tags
    
    liveness_probe=each.value.liveness_probe
    cpu=lookup(each.value,"cpu",0.25)
    memory=lookup(each.value,"memory","0.5Gi")
    max_replicas=lookup(each.value,"max_replicas",1)
    min_replicas=lookup(each.value,"min_replicas",1)

    appgw_hostname_override=lookup(each.value,"appgw_hostname_override",false)
}