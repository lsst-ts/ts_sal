#!/bin/bash

# SAL Kafka Environment Setup
# Source this before running SAL/Kafka executables: source salenv_kafka.sh

echo "Setting up SAL Kafka environment..."

# Required variables
export LSST_KAFKA_LOCAL_SCHEMAS=${LSST_KAFKA_LOCAL_SCHEMAS:-${SAL_WORK_DIR:-/tmp/sal_work}}
export LSST_KAFKA_IP=${LSST_KAFKA_IP:-127.0.0.1}
export LSST_SCHEMA_REGISTRY_URL=${LSST_SCHEMA_REGISTRY_URL:-http://schema-registry:8081}
export LSST_KAFKA_SCHEMA_REGISTRY=${LSST_SCHEMA_REGISTRY_URL}
export LSST_KAFKA_PREFIX=${LSST_KAFKA_PREFIX:-sal}

# Security configuration:
# LSST_KAFKA_SECURITY_PROTOCOL - Transport layer security:
#   PLAINTEXT     - No encryption, no authentication (development)
#   SSL           - SSL/TLS encryption, no SASL authentication
#   SASL_PLAINTEXT - SASL authentication over unencrypted connection
#   SASL_SSL      - SASL authentication over SSL/TLS (production)
# LSST_KAFKA_SECURITY_MECHANISM - SASL authentication method (only when protocol includes SASL):
#   PLAIN         - Username/password in plaintext
#   SCRAM-SHA-256 - Salted Challenge Response with SHA-256
#   SCRAM-SHA-512 - Salted Challenge Response with SHA-512 (more secure)
#   GSSAPI        - Kerberos authentication
export LSST_KAFKA_SECURITY_PROTOCOL=${LSST_KAFKA_SECURITY_PROTOCOL:-PLAINTEXT}

export LSST_KAFKA_SECURITY_MECHANISM=${LSST_KAFKA_SECURITY_MECHANISM:-SCRAM-SHA-512}
# Handle SASL mechanism - unset if protocol is PLAINTEXT (no SASL used)
if [ "${LSST_KAFKA_SECURITY_PROTOCOL}" = "PLAINTEXT" ] || [ "${LSST_KAFKA_SECURITY_PROTOCOL}" = "SSL" ]; then
    unset LSST_KAFKA_SECURITY_MECHANISM
elif [ -n "${LSST_KAFKA_SECURITY_MECHANISM:-}" ]; then
    export LSST_KAFKA_SECURITY_MECHANISM
fi

export LSST_KAFKA_BROKER_ADDR=${LSST_KAFKA_BROKER_ADDR:-broker:29092}
# Optional performance/debug settings
export LSST_SAL_DEBUG_LEVEL=${LSST_SAL_DEBUG_LEVEL:-0}
export LSST_KAFKA_HISTORYSYNC=${LSST_KAFKA_HISTORYSYNC:-0}
export LSST_KAFKA_PRODUCER_WAIT_ACKS=${LSST_KAFKA_PRODUCER_WAIT_ACKS:-1}
export LSST_KAFKA_MAX_QUEUE_MS=${LSST_KAFKA_MAX_QUEUE_MS:-100}
export LSST_KAFKA_MAX_QUEUE_MSG=${LSST_KAFKA_MAX_QUEUE_MSG:-100000}
export LSST_KAFKA_TLM_FLUSH_MS=${LSST_KAFKA_TLM_FLUSH_MS:-100}
export LSST_KAFKA_CMDEVT_FLUSH_MS=${LSST_KAFKA_CMDEVT_FLUSH_MS:-100}

# Optional security and configuration - unset if empty
if [ -z "${LSST_KAFKA_SECURITY_USERNAME:-}" ]; then
    unset LSST_KAFKA_SECURITY_USERNAME
else
    export LSST_KAFKA_SECURITY_USERNAME
fi

if [ -z "${LSST_KAFKA_SECURITY_PASSWORD:-}" ]; then
    unset LSST_KAFKA_SECURITY_PASSWORD
else
    export LSST_KAFKA_SECURITY_PASSWORD
fi

if [ -z "${LSST_KAFKA_DEBUG_CONTEXT:-}" ]; then
    unset LSST_KAFKA_DEBUG_CONTEXT
else
    export LSST_KAFKA_DEBUG_CONTEXT
fi

if [ -z "${LSST_KAFKA_BROKER_CLIENT_CONFIGURATION:-}" ]; then
    unset LSST_KAFKA_BROKER_CLIENT_CONFIGURATION
else
    export LSST_KAFKA_BROKER_CLIENT_CONFIGURATION
fi

if [ -z "${LSST_KAFKA_PRODUCER_CONFIGURATION:-}" ]; then
    unset LSST_KAFKA_PRODUCER_CONFIGURATION
else
    export LSST_KAFKA_PRODUCER_CONFIGURATION
fi

if [ -z "${LSST_KAFKA_CONSUMER_CONFIGURATION:-}" ]; then
    unset LSST_KAFKA_CONSUMER_CONFIGURATION
else
    export LSST_KAFKA_CONSUMER_CONFIGURATION
fi

echo "SAL Kafka environment configured:"
echo "  LSST_KAFKA_LOCAL_SCHEMAS: $LSST_KAFKA_LOCAL_SCHEMAS"
echo "  LSST_KAFKA_IP: $LSST_KAFKA_IP"
echo "  LSST_SCHEMA_REGISTRY_URL: $LSST_SCHEMA_REGISTRY_URL"
echo "  LSST_KAFKA_PREFIX: $LSST_KAFKA_PREFIX"
echo ""
echo "Ready to run SAL/Kafka executables!"

