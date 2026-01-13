#!/usr/bin/env bash

# includes
# ########

FOLDER_bash=$(pwd)/bash
source "${FOLDER_bash}/logging.sh" || { echo "ERROR: Failed to source logging.sh" >&2; exit 1; }
source "${FOLDER_bash}/azure.sh" || { echo "ERROR: Failed to source azure.sh"; exit 1; }
source "${FOLDER_bash}/ansible.sh" || { echo "ERROR: Failed to source ansible.sh"; exit 1; }
source "${FOLDER_bash}/system.sh" || { echo "ERROR: Failed to source system.sh"; exit 1; }

# sanity check
function sanity_check() {

    local REQUIRED_VARS=(
        LOG_VERBOSE
        ARM_CLIENT_ID
        ARM_CLIENT_CERT_PATH
        ARM_CLIENT_CERT_BASE64
        ARM_TENANT_ID
        ARM_SUBSCRIPTION_ID

        ANSIBLE_USER
        ANSIBLE_PORT
        ANSIBLE_SSH_KEY_BASE64
        ANSIBLE_DEPLOY_PATH

        MY_POSTGRES_HOST
        MY_POSTGRES_HOST_IP
        MY_POSTGRES_DATABASE
        MY_POSTGRES_USER
        MY_POSTGRES_PASSWORD
    )

    local missing_vars=()
    for var in "${REQUIRED_VARS[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("${var}")
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Missing required environment variables for deployment: ${missing_vars[*]}"
    fi
}

sanity_check

function deploy_postgres_with_ansible() {
    log_info "Deploy PostgreSQL with Ansible..."

    # Fetch cert and key
    azure_fetch_tls_cert_and_key \
        --vaultName "${AZURE_KEYVAULT_NAME}" \
        --certName "${AZURE_CERT_NAME}" \
        --keyName "${AZURE_KEY_NAME}" \
        --certsDirOutput $(pwd)/certs

    cd ansible >/dev/null 2>&1
    
    ensure_command shred
    ensure_command trap
    
    # Setup SSH key
    echo "${ANSIBLE_SSH_KEY_BASE64}" |base64 -d >/tmp/ansible_ssh_key
    chmod 600 /tmp/ansible_ssh_key
    trap 'shred -u /tmp/ansible_ssh_key 2>/dev/null || true' EXIT

    # Run Ansible playbook
    run ansible-playbook deploy-postgres.yml
    
    cd - >/dev/null 2>&1
    
    log_info "Deploy PostgreSQL with Ansible completed successfully."
}

deploy_postgres_with_ansible
