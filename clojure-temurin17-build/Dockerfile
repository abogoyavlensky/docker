FROM clojure:temurin-17-tools-deps-1.11.1.1386-bullseye-slim

# Install nodejs
RUN apt-get update \
  && apt-get install curl -y \
  && curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh \
  && bash nodesource_setup.sh \
  && apt-get install nodejs -y

# Fetch formatter binary
ENV CLJSTYLE_VERSION=0.15.0
RUN curl -L https://github.com/greglook/cljstyle/releases/download/${CLJSTYLE_VERSION}/cljstyle_${CLJSTYLE_VERSION}_linux.tar.gz -o cljstyle.tar.gz \
  && tar -xzf cljstyle.tar.gz \
  && rm -rf cljstyle.tar.gz \
  && mv cljstyle /usr/local/bin/cljstyle

# Install linter
ENV CLJ_KONOD_VERSION=2023.07.13
RUN curl -L https://github.com/borkdude/clj-kondo/releases/download/v${CLJ_KONOD_VERSION}/clj-kondo-${CLJ_KONOD_VERSION}-linux-amd64.zip -o clj-kondo.zip \
  && jar -xvf clj-kondo.zip \
  && chmod +x clj-kondo \
  && mv clj-kondo /usr/local/bin/clj-kondo

# Install Taskfile
ENV TASKFILE_VERSION=3.28.0
RUN curl -L https://github.com/go-task/task/releases/download/v${TASKFILE_VERSION}/task_linux_386.deb -o task.deb \
  && dpkg -i task.deb

# Dir for application
WORKDIR /app
