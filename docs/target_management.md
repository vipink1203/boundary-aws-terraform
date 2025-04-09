# Boundary Target Management Guide

This guide provides step-by-step instructions for adding and managing target hosts in your HashiCorp Boundary deployment, with a focus on SSH key authentication.

## Prerequisites

- Operational Boundary deployment (following the [Deployment Guide](deployment_guide.md))
- Boundary CLI installed
- Administrative access to Boundary
- SSH keys for target authentication

## Concepts

Before adding targets, understand these key Boundary concepts:

1. **Scopes**: Organizational units that contain resources
2. **Projects**: Collections of resources within a scope
3. **Hosts**: Individual machines that can be targeted
4. **Host Sets**: Groups of hosts with shared characteristics
5. **Host Catalogs**: Collections of hosts defined statically or dynamically
6. **Targets**: Endpoints that users can connect to
7. **Credential Stores**: Places where credentials are stored securely
8. **Credential Libraries**: Methods to retrieve credentials from stores

## Step 1: Authenticate to Boundary

```bash
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin \
  -password=your-admin-password
```

Save the token for future commands.

## Step 2: Create a Project

If you don't already have a project for your targets:

```bash
boundary scopes list -recursive  # Find your org scope ID

boundary projects create \
  -scope-id=o_1234567890 \
  -name="Production Servers" \
  -description="Production environment servers"
```

Note the project ID returned (e.g., `p_1234567890`).

## Step 3: Create a Static Host Catalog

```bash
boundary host-catalogs create static \
  -scope-id=p_1234567890 \
  -name="Production Hosts" \
  -description="Production environment static hosts"
```

Note the host catalog ID returned (e.g., `hc_1234567890`).

## Step 4: Add Hosts to the Catalog

For each server you want to add:

```bash
boundary hosts create static \
  -host-catalog-id=hc_1234567890 \
  -name="web-server-1" \
  -description="Production Web Server 1" \
  -address="10.0.1.100"
```

Note the host ID returned (e.g., `h_1234567890`).

## Step 5: Create a Host Set

```bash
boundary host-sets create static \
  -host-catalog-id=hc_1234567890 \
  -name="Web Servers" \
  -description="Production Web Servers"
```

Note the host set ID returned (e.g., `hs_1234567890`).

## Step 6: Add Hosts to the Host Set

```bash
boundary host-sets add-hosts \
  -id=hs_1234567890 \
  -host=h_1234567890
```

Repeat for each host you want to add to this host set.

## Step 7: Create a Credential Store

For SSH key authentication, create a static credential store:

```bash
boundary credential-stores create static \
  -scope-id=p_1234567890 \
  -name="SSH Keys" \
  -description="SSH key credentials for servers"
```

Note the credential store ID returned (e.g., `cs_1234567890`).

## Step 8: Add SSH Key Credential

```bash
boundary credentials create ssh-private-key \
  -credential-store-id=cs_1234567890 \
  -name="Admin SSH Key" \
  -description="Admin SSH key for production servers" \
  -username="admin-user" \
  -private-key-path="/path/to/your/private/key"
```

Note the credential ID returned (e.g., `cred_1234567890`).

## Step 9: Create a Target

Now create a target that connects the host set with the appropriate connection details:

```bash
boundary targets create ssh \
  -scope-id=p_1234567890 \
  -name="SSH to Web Servers" \
  -description="SSH access to production web servers" \
  -default-port=22 \
  -session-connection-limit=-1 \
  -host-set-ids=hs_1234567890
```

Note the target ID returned (e.g., `t_1234567890`).

## Step 10: Associate Credential with Target

```bash
boundary targets add-credential-sources \
  -id=t_1234567890 \
  -credential-source=cred_1234567890 \
  -application-credential-source=true  # This means Boundary will inject the credential
```

## Step 11: Grant Access to Users

Assign the appropriate roles to users:

```bash
boundary roles add-grants \
  -id=r_1234567890 \
  -grant='id=t_1234567890;actions=authorize-session,list,read'
```

## Step 12: Connect to Target

Users can now connect to the target using:

```bash
boundary connect ssh -target-id=t_1234567890
```

## Best Practices for Target Management

1. **Logical Organization**: Group related hosts into host sets
2. **Credential Rotation**: Regularly update SSH keys in the credential store
3. **Least Privilege**: Grant only necessary permissions to users
4. **Descriptive Naming**: Use clear, descriptive names for all resources
5. **Session Management**: Set appropriate session time limits and monitoring
6. **Documentation**: Keep track of all targets and their purposes

## Terraform Management (Optional)

For managing targets as code, add the following to your Terraform configuration:

```hcl
# Create a static host catalog
resource "boundary_host_catalog_static" "example" {
  name        = "Production Hosts"
  description = "Production environment static hosts"
  scope_id    = boundary_scope.project.id
}

# Create a host
resource "boundary_host_static" "example" {
  name            = "web-server-1"
  description     = "Production Web Server 1"
  address         = "10.0.1.100"
  host_catalog_id = boundary_host_catalog_static.example.id
}

# Create a host set
resource "boundary_host_set_static" "example" {
  name            = "Web Servers"
  description     = "Production Web Servers"
  host_catalog_id = boundary_host_catalog_static.example.id
  host_ids        = [boundary_host_static.example.id]
}

# Create a credential store
resource "boundary_credential_store_static" "example" {
  name        = "SSH Keys"
  description = "SSH key credentials for servers"
  scope_id    = boundary_scope.project.id
}

# Create an SSH key credential
resource "boundary_credential_ssh_private_key" "example" {
  name                = "Admin SSH Key"
  description         = "Admin SSH key for production servers"
  credential_store_id = boundary_credential_store_static.example.id
  username            = "admin-user"
  private_key         = file("/path/to/your/private/key")
}

# Create a target
resource "boundary_target" "example" {
  name         = "SSH to Web Servers"
  description  = "SSH access to production web servers"
  type         = "ssh"
  scope_id     = boundary_scope.project.id
  default_port = "22"
  
  host_source_ids = [
    boundary_host_set_static.example.id
  ]
  
  credential_source_ids = [
    boundary_credential_ssh_private_key.example.id
  ]
  
  session_connection_limit = -1  # Unlimited connections
}
```

## Troubleshooting Target Connections

If users have issues connecting to targets:

1. **Verify Network Connectivity**: Ensure the Boundary worker can reach the target
2. **Check Credentials**: Verify SSH key permissions and user existence on the target
3. **Inspect Session Details**: Use `boundary sessions read -id=s_1234567890` to view session info
4. **Review Logs**: Check Boundary controller and worker logs for connection errors
5. **Test Direct Connection**: Try connecting directly to verify basic SSH functionality

## Next Steps

- Set up [User Management](user_management.md)
- Configure session recording for auditing
- Implement additional authentication methods
