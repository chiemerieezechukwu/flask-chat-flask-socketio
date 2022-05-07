#!/bin/bash
set -xe

if [[ $DATABASE_URL == *"postgres"* ]]; then
  echo "Waiting for postgres..."

  while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
      sleep 0.1
  done

  echo "PostgreSQL started"
fi

exec "$@"

echo "Starting server"
gunicorn --bind 0.0.0.0:5000 run:app runserver