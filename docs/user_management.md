# Boundary User Management Guide

This guide provides step-by-step instructions for managing users, authentication methods, and authorization policies in HashiCorp Boundary.

## Prerequisites

- Operational Boundary deployment (following the [Deployment Guide](deployment_guide.md))
- Boundary CLI installed
- Administrative access to Boundary

## Key User Management Concepts

Before managing users, understand these key Boundary concepts:

1. **Auth Methods**: Ways users can authenticate (password, OIDC, etc.)
2. **Accounts**: User identities within an auth method
3. **Users**: Representations of people that can be assigned to roles
4. **Groups**: Collections of users for easier management
5. **Roles**: Definitions of permissions assigned to users and groups
6. **Grants**: Specific permissions attached to roles

## Step 1: Authenticate as an Administrator

```bash
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin \
  -password=your-admin-password
```

## Step 2: Create an Organizational Scope

If not already created:

```bash
boundary scopes create \
  -scope-id=global \
  -name="My Organization" \
  -description="My organization's scope"
```

Note the scope ID returned (e.g., `o_1234567890`).

## Step 3: Create Users

Create individual user identities:

```bash
boundary users create \
  -scope-id=o_1234567890 \
  -name="John Doe" \
  -description="DevOps Engineer"
```

Note the user ID returned (e.g., `u_1234567890`).

## Step 4: Create Groups (Optional)

For easier management, create groups of users:

```bash
boundary groups create \
  -scope-id=o_1234567890 \
  -name="DevOps Team" \
  -description="DevOps team members"
```

Note the group ID returned (e.g., `g_1234567890`).

## Step 5: Add Users to Groups

```bash
boundary groups add-members \
  -id=g_1234567890 \
  -member=u_1234567890
```

## Step 6: Create Password Auth Method

```bash
boundary auth-methods create password \
  -scope-id=o_1234567890 \
  -name="Password Auth" \
  -description="Password authentication for users"
```

Note the auth method ID returned (e.g., `ampw_1234567890`).

## Step 7: Create User Accounts

Create accounts within the auth method:

```bash
boundary accounts create password \
  -auth-method-id=ampw_1234567890 \
  -login-name=johndoe \
  -password=secure-password \
  -name="John Doe Account"
```

Note the account ID returned (e.g., `acctpw_1234567890`).

## Step 8: Associate Accounts with Users

```bash
boundary users set-accounts \
  -id=u_1234567890 \
  -account=acctpw_1234567890
```

## Step 9: Create Roles

Create roles to define permissions:

```bash
boundary roles create \
  -scope-id=o_1234567890 \
  -name="Dev Access" \
  -description="Developer access to development targets"
```

Note the role ID returned (e.g., `r_1234567890`).

## Step 10: Add Principals to Roles

Add users or groups as principals to roles:

```bash
# Add a user directly
boundary roles add-principals \
  -id=r_1234567890 \
  -principal=u_1234567890

# Or add a group
boundary roles add-principals \
  -id=r_1234567890 \
  -principal=g_1234567890
```

## Step 11: Add Grants to Roles

Specify what the role allows:

```bash
# Grant access to a specific target
boundary roles add-grants \
  -id=r_1234567890 \
  -grant='id=t_1234567890;actions=authorize-session,list,read'

# Grant access to a project scope
boundary roles add-grants \
  -id=r_1234567890 \
  -grant='id=p_1234567890;actions=list,read,no-op'

# Grant access to see hosts
boundary roles add-grants \
  -id=r_1234567890 \
  -grant='type=host-catalog;actions=list,read,no-op'
```

## Step 12: Test User Access

Have the user log in and verify access:

```bash
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=johndoe \
  -password=secure-password
```

Then try to list and connect to allowed targets:

```bash
boundary targets list -scope-id=p_1234567890
boundary connect ssh -target-id=t_1234567890
```

## Managing User Authentication Methods

### Password Authentication Best Practices

1. Enforce strong passwords
2. Regularly rotate passwords
3. Limit failed login attempts
4. Prompt for password changes

### Setting Up OIDC Authentication (Enterprise Feature)

1. Create an OIDC auth method:

```bash
boundary auth-methods create oidc \
  -scope-id=o_1234567890 \
  -name="Corporate SSO" \
  -description="OIDC authentication with corporate SSO" \
  -issuer="https://your-identity-provider.com" \
  -client-id="your-client-id" \
  -client-secret="your-client-secret" \
  -signing-algorithms="RS256" \
  -api-url-prefix="https://your-boundary-address" \
  -callback-url="https://your-boundary-address/v1/auth-methods/oidc:authenticate:callback" \
  -claims-scopes="email,profile"
```

2. Create OIDC managed groups (if using groups from IdP):

```bash
boundary managed-groups create oidc \
  -auth-method-id=amoidc_1234567890 \
  -name="OIDC Admins" \
  -description="Administrators from OIDC provider" \
  -filter="groups.contains(\"admin-group\")"
```

3. Assign managed groups to roles:

```bash
boundary roles add-principals \
  -id=r_1234567890 \
  -principal=mgoidc_1234567890
```

## Managing User Authorization Policies

### Principle of Least Privilege

1. Grant only the minimal permissions needed
2. Use time-based grants for temporary access
3. Regularly audit permissions
4. Remove access when no longer needed

### Role Hierarchy Example

For a typical organization:

1. **Admin Role**: Full management capabilities
2. **Ops Role**: Target management and connection
3. **Developer Role**: Connection to development targets only
4. **Read-Only Role**: View resources but not connect

## Terraform Management

For managing users and access as code:

```hcl
# Create a user
resource "boundary_user" "example" {
  name        = "John Doe"
  description = "DevOps Engineer"
  scope_id    = boundary_scope.org.id
}

# Create a group
resource "boundary_group" "example" {
  name        = "DevOps Team"
  description = "DevOps team members"
  member_ids  = [boundary_user.example.id]
  scope_id    = boundary_scope.org.id
}

# Create an auth method
resource "boundary_auth_method_password" "example" {
  name        = "Password Auth"
  description = "Password authentication for users"
  scope_id    = boundary_scope.org.id
}

# Create an account
resource "boundary_account_password" "example" {
  name           = "John Doe Account"
  description    = "John's password account"
  auth_method_id = boundary_auth_method_password.example.id
  login_name     = "johndoe"
  password       = "secure-password"
}

# Associate account with user
resource "boundary_user" "with_account" {
  name        = "John Doe"
  description = "DevOps Engineer"
  scope_id    = boundary_scope.org.id
  account_ids = [boundary_account_password.example.id]
}

# Create a role
resource "boundary_role" "example" {
  name        = "Dev Access"
  description = "Developer access to development targets"
  scope_id    = boundary_scope.org.id
  
  principal_ids = [
    boundary_user.example.id,
    boundary_group.example.id
  ]
  
  grant_strings = [
    "id=${boundary_target.dev_servers.id};actions=authorize-session,list,read",
    "id=${boundary_scope.project.id};actions=list,read,no-op",
    "type=host-catalog;actions=list,read,no-op"
  ]
}
```

## Troubleshooting User Access Issues

If users have trouble accessing resources:

1. **Verify Authentication**: Check if the user can log in successfully
2. **Check Role Assignments**: Ensure the user is assigned to the correct roles
3. **Review Grants**: Verify the roles have appropriate grants
4. **Inspect Session Errors**: Check error messages during connection attempts
5. **Review Logs**: Check Boundary controller logs for auth issues

## Best Practices for User Management

1. **Use Groups**: Manage permissions via groups rather than individual users
2. **Federated Identity**: Use OIDC when possible for centralized identity management
3. **Regular Audits**: Periodically review user access and permissions
4. **Just-in-Time Access**: Implement temporary access when possible
5. **Documenting Roles**: Keep clear documentation of role purposes and permissions
6. **Role Separation**: Create distinct roles for different functions and environments

## Next Steps

- Implement [Multi-Factor Authentication](mfa_guide.md) (Enterprise feature)
- Set up regular user access reviews
- Integrate with your CI/CD pipeline for automated user provisioning
