ENVIRONMENT=${1:-"dev"}
FILE_secrets=".devcontainer/.env.${ENVIRONMENT}"

# Upgrades
# ########

az upgrade --yes

# Load secrets
# ############

if [ -f "${FILE_secrets}" ]; then

    echo "Loading secrets from ${FILE_secrets}..."

    cp "${FILE_secrets}" ~/.devcontainer_env
    # REMARK: set -a and set +a are used to export all variables in the file so that subshells can access them
    grep -q "devcontainer_env" ~/.bashrc || echo 'if [ -f ~/.devcontainer_env ]; then set -a; source ~/.devcontainer_env; set +a; fi' >> ~/.bashrc
    . ~/.devcontainer_env
else
    echo "No secrets file found for environment: ${ENVIRONMENT}"
    
    exit 1
fi

# AZURE LOGIN
# ###########

if  [ -n "${ARM_CLIENT_ID}" ] && \
    [ -n "${ARM_CLIENT_CERT_PATH}" ] && \
    [ -n "${ARM_CLIENT_CERT_BASE64}" ] && \
    [ -n "${ARM_TENANT_ID}" ] && \
    [ -n "${ARM_SUBSCRIPTION_ID}" ]; then
    
    if command -v az >/dev/null; then

        mkdir -p "$(dirname "${ARM_CLIENT_CERT_PATH}")" >/dev/null 2>&1 || true

        echo "${ARM_CLIENT_CERT_BASE64}" |base64 -d >"${ARM_CLIENT_CERT_PATH}"
        chmod 600 "${ARM_CLIENT_CERT_PATH}"

        if az login --service-principal \
            --username ${ARM_CLIENT_ID} \
            --certificate "${ARM_CLIENT_CERT_PATH}" \
            --tenant ${ARM_TENANT_ID} >/dev/null 2>&1; then

            echo "[AZURE LOGIN] Azure CLI login successful."
        else
            echo "[AZURE LOGIN] Azure CLI login failed."
        fi
    else
        echo "[AZURE LOGIN] Azure CLI not found."
    fi
else
    echo "[AZURE LOGIN] Missing required credentials. Login skipped."
fi

# AWS LOGIN
# #########

if ! command -v aws >/dev/null || \
    [ -z "${AWS_ACCESS_KEY_ID}" ] || \
    [ -z "${AWS_SECRET_ACCESS_KEY}" ] || \
    [ -z "${AWS_DEFAULT_REGION}" ]; then

    echo "[AWS LOGIN] AWS CLI login can not be performed."

elif aws sts get-caller-identity >/dev/null 2>&1; then
    echo "[AWS LOGIN] AWS CLI login already executed."

elif aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID && \
     aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY && \
     aws configure set default.region $AWS_DEFAULT_REGION && \
     aws sts get-caller-identity >/dev/null 2>&1; then
    
    echo "[AWS LOGIN] AWS CLI login successful."
else
    echo "[AWS LOGIN] AWS CLI login failed."
fi
