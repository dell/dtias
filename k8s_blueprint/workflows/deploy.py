#Sample Workflow

from cloudify.decorators import workflow
from cloudify import ctx
from kubernetes import client, config
import yaml

@workflow
def deploy_k8s_resources(ctx, **kwargs):
    """
    A custom workflow to deploy Kubernetes resources using the kubeconfig and resource definition provided.
    """
    # Load inputs
    kubeconfig_path = ctx.workflow_parameters.get('kubeconfig')
    resource_definition_path = ctx.workflow_parameters.get('resource_definition')

    if not kubeconfig_path or not resource_definition_path:
        raise ValueError("Both 'kubeconfig' and 'resource_definition' inputs are required.")

    # Load kubeconfig
    ctx.logger.info(f"Loading kubeconfig from: {kubeconfig_path}")
    config.load_kube_config(kubeconfig_path)

    # Load the Kubernetes resource definition
    ctx.logger.info(f"Loading Kubernetes resource definition from: {resource_definition_path}")
    with open(resource_definition_path, 'r') as f:
        resource_definition = yaml.safe_load(f)

    # Initialize Kubernetes API clients
    api_client = client.ApiClient()
    core_api = client.CoreV1Api(api_client)
    apps_api = client.AppsV1Api(api_client)

    # Deploy the resource
    kind = resource_definition.get('kind')
    if kind == 'Deployment':
        ctx.logger.info("Applying Deployment resource.")
        namespace = resource_definition['metadata'].get('namespace', 'default')
        apps_api.create_namespaced_deployment(
            body=resource_definition,
            namespace=namespace
        )
        ctx.logger.info("Deployment created successfully.")
    elif kind == 'Service':
        ctx.logger.info("Applying Service resource.")
        namespace = resource_definition['metadata'].get('namespace', 'default')
        core_api.create_namespaced_service(
            body=resource_definition,
            namespace=namespace
        )
        ctx.logger.info("Service created successfully.")
    else:
        raise ValueError(f"Unsupported resource kind: {kind}")

    ctx.logger.info("Kubernetes resources deployed successfully.")

