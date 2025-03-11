#!/bin/bash

# Script to extract Azure authentication details and create a .env.local file
# This script assumes you're already logged in with the Azure CLI (az)

# Set error handling
set -e

# Send initial message to stderr so it doesn't get redirected
>&2 echo "Gathering Azure authentication details..."

# Check if az command is available
if ! command -v az &> /dev/null; then
    >&2 echo "Error: Azure CLI (az) is not installed or not in the PATH"
    >&2 echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    >&2 echo "Error: Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
    >&2 echo "Error: Could not retrieve subscription ID"
    exit 1
fi

# Get tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
if [ -z "$TENANT_ID" ]; then
    >&2 echo "Error: Could not retrieve tenant ID"
    exit 1
fi

# Create a service principal and get client ID and secret
>&2 echo "Creating a service principal for authentication..."
SP_INFO=$(az ad sp create-for-rbac --name "terraform-sp-$(date +%Y%m%d%H%M%S)" --role Contributor --scopes /subscriptions/$SUBSCRIPTION_ID)

CLIENT_ID=$(echo $SP_INFO | grep -o '"appId": *"[^"]*"' | cut -d'"' -f4)
CLIENT_SECRET=$(echo $SP_INFO | grep -o '"password": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    >&2 echo "Error: Could not create service principal or extract credentials"
    exit 1
fi

# Output the environment variables to stdout
echo "export ARM_SUBSCRIPTION_ID=\"$SUBSCRIPTION_ID\""
echo "export ARM_TENANT_ID=\"$TENANT_ID\""
echo "export ARM_CLIENT_ID=\"$CLIENT_ID\""
echo "export ARM_CLIENT_SECRET=\"$CLIENT_SECRET\""
echo "export TERM=xterm-256color"

# Print usage instructions to stderr so they don't get redirected
>&2 echo ""
>&2 echo "Authentication details have been output to stdout."
>&2 echo "You can redirect this to a file using: ./script.sh > .env.local"
>&2 echo ""
>&2 echo "WARNING: If you save these credentials to a file, it will contain sensitive information."
>&2 echo "Please ensure it is not committed to version control and is properly secured."
>&2 echo "Consider running: chmod 600 .env.local"
