FROM buildpack-deps:20.04-curl as BASE

# Fetch formatter binary
ARG CLJSTYLE_VERSION
RUN curl -L https://github.com/greglook/cljstyle/releases/download/${CLJSTYLE_VERSION}/cljstyle_${CLJSTYLE_VERSION}_linux.tar.gz -o cljstyle.tar.gz \
  && tar -xzf cljstyle.tar.gz \
  && rm -rf cljstyle.tar.gz


FROM frolvlad/alpine-glibc:alpine-3.12_glibc-2.32

COPY --from=BASE /cljstyle /usr/local/bin/cljstyle

WORKDIR /app
CMD ["cljstyle"]
