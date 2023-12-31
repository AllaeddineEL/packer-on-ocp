#!/bin/bash -l

# HCP Packer API shortcuts
export HCP_PACKER_BASE_URL=https://api.cloud.hashicorp.com/packer/2021-04-30/organizations/${HCP_ORGANIZATION_ID}/projects/${HCP_PROJECT_ID}

# Specific to this exercise
export HCP_PACKER_BUCKET_SLUG="path-to-packer-container"
export HCP_PACKER_CHANNEL_SLUG="path-to-packer-container-channel"
export HCP_PACKER_CHANNEL_SLUG2="path-to-packer-vm-channel"

export HCP_PACKER_API_GET_REGISTRY=${HCP_PACKER_BASE_URL}/registry
export HCP_PACKER_API_CREATE_CHANNEL=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}/channels
export HCP_PACKER_API_PATCH_CHANNEL=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}/channels/${HCP_PACKER_CHANNEL_SLUG}
export HCP_PACKER_API_LIST_BUCKETS=${HCP_PACKER_BASE_URL}/images
export HCP_PACKER_API_GET_BUCKET=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}
export HCP_PACKER_DELETE_BUCKET=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}


export HCP_PACKER_API_CREATE_CHANNEL2=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}/channels
export HCP_PACKER_API_PATCH_CHANNEL2=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}/channels/${HCP_PACKER_CHANNEL_SLUG2}
export HCP_PACKER_API_GET_BUCKET2=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}
export HCP_PACKER_DELETE_BUCKET2=${HCP_PACKER_BASE_URL}/images/${HCP_PACKER_BUCKET_SLUG}

# TFC API shortcuts
export TCF_API_BASE_URL=https://app.terraform.io/api/v2
export TFE_WORKSPACE_ID="temp"
export TFE_WORKSPACE="path-to-packer"
export TFE_WORKSPACE2="path-to-packer-vm"


export TFC_API_ACCT_DETAILS=${TCF_API_BASE_URL}/account/details
export TFC_API_SHOW_WORKSPACE=${TCF_API_BASE_URL}/organizations/${TFE_ORG}/workspaces/${TFE_WORKSPACE}
export TFC_API_DELETE_WORKSPACE=${TCF_API_BASE_URL}/organizations/${TFE_ORG}/workspaces/${TFE_WORKSPACE}
export TFC_API_DELETE_WORKSPACE2=${TCF_API_BASE_URL}/organizations/${TFE_ORG}/workspaces/${TFE_WORKSPACE2}
export TFC_API_PUSH_VARS=${TCF_API_BASE_URL}/vars
export TFC_API_LIST_RUNTASK=${TCF_API_BASE_URL}/organizations/${TFE_ORG}/tasks

# This shortcut is here for consistency but won't work because we don't know the workspace id. 
# Even when this file is sourced by the workflow watchdog, it won't work until the workspace id is sourced.

export TFC_API_ATTACH_RUNTASK=${TCF_API_BASE_URL}/workspaces/${TFE_WORKSPACE_ID}/tasks