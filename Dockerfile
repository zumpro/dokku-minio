FROM minio/minio:latest

LABEL name="MinIO" \
      vendor="MinIO Inc <dev@min.io>" \
      maintainer="MinIO Inc <dev@min.io>"

# Параметры конфигурации
ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key \
    MINIO_KMS_SECRET_KEY_FILE=kms_master_key \
    MINIO_UPDATE_MINISIGN_PUBKEY="RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav"

# Порты, через которые будет доступен MinIO
EXPOSE 9000 9001

# Команда для запуска MinIO
CMD ["server", "--address", ":9000", "/data"]
