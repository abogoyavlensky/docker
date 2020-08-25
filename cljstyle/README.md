# abogoyavlensky/cljstyle

Docker image for [cljstyle](https://github.com/greglook/cljstyle) tool.
Based on the [alpine](https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc)
image with addition of `glibc` library.

Supposed to be used locally or in CI for formatting Clojure files.

## Usage examples

Run with docker:

```shell
docker run -v $PWD:/app --rm abogoyavlensky/cljstyle cljstyle check --report src
```

Run with docker-compose:

```yaml
version: "3.8"

services:
  fmt:
    image: abogoyavlensky/cljstyle
    command: cljstyle check --report src
    volumes:
      - .:/app
```

```shell
docker-compose run fmt
```

*More info about configuration and usages please see in origin [repository](https://github.com/greglook/cljstyle/blob/master/doc/integrations.md).*
