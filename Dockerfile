FROM public.ecr.aws/prima/elixir:1.13.4-1

WORKDIR /code

COPY entrypoint /code/entrypoint

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -s -- && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs sendemail libnet-ssleay-perl libio-socket-ssl-perl && \
    apt-get clean && \
    npm install -g graphql-schema-diff@^2.2.0 && \
    chown -R app:app /code

# Serve per avere l'owner dei file scritti dal container uguale all'utente Linux sull'host
USER app

ENTRYPOINT ["./entrypoint"]
