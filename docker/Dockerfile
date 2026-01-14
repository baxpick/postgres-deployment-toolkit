FROM postgres:18

# Install essential PostgreSQL extensions and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # postgresql-contrib includes pg_stat_statements and other essential extensions
    postgresql-contrib \
    # Cleanup to reduce image size
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy custom PostgreSQL configuration
COPY docker/postgresql.conf /etc/postgresql/postgresql.conf

# Set proper permissions for configuration file
RUN chmod 644 /etc/postgresql/postgresql.conf

# Accept build-time argument for custom PostgreSQL port
ARG POSTGRES_PORT=5432
ENV POSTGRES_PORT=${POSTGRES_PORT}

# Expose the custom port (overrides base image's EXPOSE 5432)
EXPOSE ${POSTGRES_PORT}

# Override default command to use custom config
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]