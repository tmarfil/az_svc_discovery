#!/bin/bash

# Function to check AWS connectivity
check_aws()
{
  echo "Checking AWS connectivity..."
  if command -v aws > /dev/null 2>&1; then
    # Get account info
    AWS_ACCOUNT=$(aws sts get-caller-identity 2>&1)
    if [ $? -eq 0 ]; then
      echo "✅ AWS Connection Successful"
      echo "Account Information:"
      echo "$AWS_ACCOUNT" | sed 's/^/    /'
    else
      echo "❌ AWS Connection Failed"
      echo "Error: $AWS_ACCOUNT"
    fi
  else
    echo "❌ AWS CLI not installed"
  fi
  echo
}

# Function to check Azure connectivity
check_azure()
{
  echo "Checking Azure connectivity..."
  if command -v az > /dev/null 2>&1; then
    # Get account info
    AZURE_ACCOUNT=$(az account show 2>&1)
    if [ $? -eq 0 ]; then
      echo "✅ Azure Connection Successful"
      echo "Account Information:"
      echo "$AZURE_ACCOUNT" | sed 's/^/    /'
    else
      echo "❌ Azure Connection Failed"
      echo "Error: $AZURE_ACCOUNT"
    fi
  else
    echo "❌ Azure CLI not installed"
  fi
  echo
}

# Function to check GCP connectivity
check_gcp()
{
  echo "Checking GCP connectivity..."
  if command -v gcloud > /dev/null 2>&1; then
    # Get account info
    GCP_ACCOUNT=$(gcloud config list account --format "value(core.account)" 2>&1)
    GCP_PROJECT=$(gcloud config list project --format "value(core.project)" 2>&1)
    if [ $? -eq 0 ]; then
      echo "✅ GCP Connection Successful"
      echo "Account Information:"
      echo "    Account: $GCP_ACCOUNT"
      echo "    Project: $GCP_PROJECT"
    else
      echo "❌ GCP Connection Failed"
      echo "Error: $GCP_ACCOUNT"
    fi
  else
    echo "❌ Google Cloud SDK not installed"
  fi
  echo
}

# Function to display usage
usage()
{
  echo "Usage: $0 [--aws|--azure|--gcp]"
  echo "Options:"
  echo "  --aws    Check only AWS connectivity"
  echo "  --azure  Check only Azure connectivity"
  echo "  --gcp    Check only GCP connectivity"
  echo "  If no option is provided, all cloud providers will be checked"
  exit 1
}

# Main script
case "$1" in
  --aws)
    check_aws
    ;;
  --azure)
    check_azure
    ;;
  --gcp)
    check_gcp
    ;;
  "")
    echo "Checking all cloud providers..."
    echo "--------------------------------"
    check_aws
    check_azure
    check_gcp
    ;;
  *)
    usage
    ;;
esac
