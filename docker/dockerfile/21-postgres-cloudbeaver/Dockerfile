FROM postgres:16-alpine
ENV LANG=C.UTF-8
COPY init/01_init.sql /docker-entrypoint-initdb.d/01_init.sql
EXPOSE 5432
CMD ["postgres"]
