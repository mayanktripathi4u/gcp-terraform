# Using Terraform to Manage GCP Resources.

Will be using below Terraform Resources.

## TF Resource `google_project_service`
In Terraform, the `google_project_service` resource is used to enable and disable APIs within a Google Cloud Project. Essentially, it lets you manage which Google services are available for use within your project. This can be crucial for automating the setup and configuration of your Google Cloud environment, ensuring that all the necessary APIs are enabled without manual intervention.

For example, if you need the Google Cloud Storage API for your project, you can enable it using the google_project_service resource in your Terraform configuration. This helps to maintain consistency and reduce human error in setting up your cloud resources.

Here's a simple example of how you might use it in your Terraform script: 

```bash
resource "google_project_service" "my_service" {
  project = "your-project-id"
  service = "storage.googleapis.com"
}
```

In this example, the Google Cloud Storage API is enabled for the specified project. You can specify other services as needed by changing the service attribute.

The `disable_on_destroy` parameter in the `google_project_service` resource determines whether the specified API should be disabled when the Terraform resource is destroyed.

By default, this parameter is set to `false`, meaning that when you delete the `google_project_service` resource, the API remains enabled in your project. However, if you set `disable_on_destroy` to true, the API will be disabled when the resource is destroyed.

There are two main ways to create multiple resources of the same type, we can use `count` which is original old way and nowadays it should only be used as a flag to enable creating a certain resources. The best way is to iterate over that array of APIs using `for_each` function.
So its going to be exactly the same resources.

Lets use for_each and iterate over API locals variable that we created, the for_each function only works with objects and we need to convert that array to an object by using toset function. With this we can create as many google project service resources as we have items in that APIs array and to reference we can use each key. If you iterate over objects you would have both each key and each value properties. This i smuch more concise way to create the same number of resources using TF and its very starightforward.

## TF Resource `google_compute_network`
The `google_compute_network` resource in Terraform is used to create and manage virtual networks (VPCs) in Google Cloud. A VPC network is a global resource that consists of a list of subnetworks in different regions. Each subnetwork has a specific IP range and can be used to group and control resources in a specific region.

Here's a basic example of how you might define a `google_compute_network` resource in your Terraform configuration:
```bash
resource "google_compute_network" "my_network" {
  name                    = "my-network"
  auto_create_subnetworks = true
}
```

explain the terraform resource "google_compute_network"
The google_compute_network resource in Terraform is used to create and manage virtual networks (VPCs) in Google Cloud. A VPC network is a global resource that consists of a list of subnetworks in different regions. Each subnetwork has a specific IP range and can be used to group and control resources in a specific region.

Here's a basic example of how you might define a google_compute_network resource in your Terraform configuration:

hcl
resource "google_compute_network" "my_network" {
  name                    = "my-network"
  auto_create_subnetworks = true
}
In this example:

* `name` specifies the name of the network.

* `auto_create_subnetworks` is a boolean flag that, if set to true, automatically creates one subnetwork per region with a predetermined CIDR range when the network is created. If set to false, you will need to manually create subnetworks, as it will disable all those subnets that generated automatically.

Some additional attributes you might find useful:

* `description`: An optional description of the network.
* `mtu`: The Maximum Transmission Unit (MTU) of packets on this network. Can be set to 1460, 1500, or 8896 bytes.
* `routing_mode`: Specifies the network-wide routing mode. Can be set to REGIONAL or GLOBAL.
Its very rare to use GLOBAL but there are some use-cases where you need it. Usually in large companies where you have clients all over the world and you want to reduce latency, and may be you gave to store data locally in those countires where you have customers.
* `delete_default_routes_on_create`: Optionally we can delete the default route to the internet, most of the time we would keep it bit best is to manage it ourself and create it inside terraform.

This parameter determines whether the default routes provided by Google Cloud should be deleted when the network is created. 

When you create a new VPC network in Google Cloud, it automatically sets up default routes that allow traffic to flow between different parts of your network and out to the internet. In some cases, you might want more control over your routing configuration and prefer to set up your own custom routes from scratch. This is where delete_default_routes_on_create comes in.

If you set delete_default_routes_on_create to true, Terraform will delete these automatically created default routes when the network is created. This allows you to define your own routes without interference from the default configurations.

Note: There are two ways TF creates dependcncies if you use a reference inside the TF resource or you can explicitly use `depends_on` property to instruct TF to create this resource only when the other one is already created.  

## TF Resource `google_compute_route`
The google_compute_route resource in Terraform is used to create and manage routes within a Google Cloud VPC network. Routes direct traffic from virtual machine (VM) instances to the appropriate destinations, either within the VPC network or external to it. They define the rules for traffic forwarding based on the destination IP ranges and the next hop.

Here's a basic example of how you might define a google_compute_route resource in your Terraform configuration:

```bash
resource "google_compute_route" "my_route" {
  name            = "my-route"
  network         = google_compute_network.my_network.name
  dest_range      = "10.0.1.0/24"
  next_hop_gateway = "default-internet-gateway"
}
```
In this example:

* `name`: Specifies the name of the route.
* `network`: Specifies the network the route applies to. This should reference an existing google_compute_network resource.
* `dest_range`: The destination range of the route, defined in CIDR notation. Traffic matching this IP range will be directed by this route.
* `next_hop_gateway`: The gateway the route will use to forward traffic. This can be a predefined gateway like default-internet-gateway.

Other attributes you might find useful:

* `description`: An optional description of the route.

* `priority`: The priority of the route. Lower values indicate higher priority. Routes with higher priority are considered before those with lower priority when multiple routes match the same destination.

* `tags`: Tags that VMs must have to match the route. This allows for selective traffic routing based on VM tags.

# TF Resource `google_compute_subnetwork`
* In AWS your subnet ranges must be subsets of VPC range.
* In GCP we do not have this constraint. 

# How to run
Initiate the Terraform
```bash
terraform init
```

Run the Plan
```bash
terraform plan
```

In case it fails, check the authentication. Seems it could fail for credentials not loaded. For this first run.
```bash
gcloud auth application-default login
```

Once authenticated, re-run the plan.

Followed by the Apply. Make sure to revivew the plan.
```bash
terraform apply

# or 
terraform apply --auto-approve
```

We should avoid using `auto-approve` flag in Production.

# Summary
This Terraform code sets up a Google Cloud Platform (GCP) environment with the following components:

1. Enabling Required APIs: The code enables several Google APIs necessary for the project, such as Compute Engine, Kubernetes Engine, Logging, and Secret Manager.

2. Creating a VPC Network: It creates a Virtual Private Cloud (VPC) network named "main" with regional routing mode and no automatically created subnetworks. Default routes are deleted.

3. Creating Subnetworks: It defines two subnetworks, "public" and "private," each with specified CIDR ranges.

4. Creating Routes: It creates a default route for outbound internet traffic.

5. Setting Up NAT Gateway: It sets up a Network Address Translation (NAT) gateway to allow private instances to access the internet.

6. Firewall Rules: It creates a firewall rule to allow SSH access through Identity-Aware Proxy (IAP).

## Here's the diagram for this setup:

1. VPC Network: "main"

* Subnetworks:

  * Public Subnetwork: 10.0.0.0/19
  * Private Subnetwork: 10.0.32.0/19
    * Secondary IP Ranges:
      * k8s-pods: 172.16.0.0/14
      * k8s-services: 172.20.0.0/18

2. NAT Gateway: Allows private instances to access the internet.

3. Default Route: For internet access.

4. Firewall Rule: Allows SSH access through IAP.

```bash
+-------------------------+
|     VPC Network: main   |
+-----------+-------------+
            |
            +-----------------------+
            |                       |
    +-------+--------+     +--------+--------+
    | Public Subnet  |     |  Private Subnet  |
    | 10.0.0.0/19    |     | 10.0.32.0/19     |
    +----------------+     +------------------+
                                   |
                                   +------------------------------+
                                   | Secondary IP Ranges          |
                                   | - k8s-pods: 172.16.0.0/14    |
                                   | - k8s-services: 172.20.0.0/18|
                                   +------------------------------+
            |
            +----------------------->  Default Route (0.0.0.0/0)
            |                             |
+------------------------+    NAT Gateway
|    Firewall Rule       |    (internet access)
| Allow IAP SSH (22/tcp) |
+------------------------+
```


