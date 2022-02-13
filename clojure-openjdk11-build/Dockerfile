FROM clojure:openjdk-11-tools-deps-1.10.3.1040-slim-buster

RUN apt-get update \
  && apt-get install curl -y

# Fetch formatter binary
ENV CLJSTYLE_VERSION=0.15.0
RUN curl -L https://github.com/greglook/cljstyle/releases/download/${CLJSTYLE_VERSION}/cljstyle_${CLJSTYLE_VERSION}_linux.tar.gz -o cljstyle.tar.gz \
  && tar -xzf cljstyle.tar.gz \
  && rm -rf cljstyle.tar.gz \
  && mv cljstyle /usr/local/bin/cljstyle

# Install linter
ENV CLJ_KONOD_VERSION=2021.12.19
RUN curl -L https://github.com/borkdude/clj-kondo/releases/download/v${CLJ_KONOD_VERSION}/clj-kondo-${CLJ_KONOD_VERSION}-linux-amd64.zip -o clj-kondo.zip \
  && jar -xvf clj-kondo.zip \
  && chmod +x clj-kondo \
  && mv clj-kondo /usr/local/bin/clj-kondo

# Install robo
RUN curl -sf https://gobinaries.com/tj/robo@0.7.0 | sh


# Install chromedriver
RUN apt-get update -y
# We need wget to set up the PPA and xvfb to have a virtual screen and unzip to install the Chromedriver
RUN apt-get install -y wget xvfb unzip gnupg
# Set up the Chrome PPA
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# Update the package list and install chrome
RUN apt-get update -y
RUN apt-get install -y google-chrome-stable
# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_VERSION 98.0.4758.80
ENV CHROMEDRIVER_DIR /chromedriver
RUN mkdir $CHROMEDRIVER_DIR
# Download and install Chromedriver
RUN wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
RUN unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR
# Put Chromedriver into the PATH
ENV PATH $CHROMEDRIVER_DIR:$PATH



# Dir for application
WORKDIR /app
