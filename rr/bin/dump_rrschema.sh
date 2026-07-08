#!/bin/sh
pg_dump -t 'rr.*' gavo | gzip > /var/www/docs/rr-dump.sql.gz
