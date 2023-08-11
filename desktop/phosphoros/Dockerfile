FROM skaha/base:latest

RUN apt-get update --yes --quiet \
    && apt-get install --yes xterm
RUN mamba install --yes -c astrorama phosphoros \
    && mamba clean --all --quiet --force --yes

CMD ["Phosphoros"]
