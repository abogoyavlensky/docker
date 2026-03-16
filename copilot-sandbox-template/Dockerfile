FROM docker/sandbox-templates:copilot

USER root

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential tools
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    unzip \
    rlwrap \
    # Development tools
    git \
    build-essential \
    # Shell utilities
    bash \
    bash-completion \
    jq \
    ripgrep \
    tree \
    less \
    nano \
    # Network tools
    openssh-client \
    # Process management
    sudo \
    procps \
    # Python (for various tools and MCP servers)
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN apt update -y && sudo apt install -y curl \
    && install -dm 755 /etc/apt/keyrings \
    && curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc 1> /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list \
    && apt update -y \
    && apt install -y mise

# Make mise-installed tools available in all shells (including non-interactive).
# ENV works in every context, unlike .bashrc which only runs in interactive bash.
ENV MISE_SHIMS_DIR="/home/agent/.local/share/mise/shims"
ENV PATH="/home/agent/.local/share/mise/shims:/home/agent/.local/bin:${PATH}"

# Setup script: imports proxy CA into Java truststore and configures Maven proxy.
# Source from both profile.d (login shells) and bash.bashrc (all interactive bash),
# since we don't control how the sandbox base image launches the agent's shell.
COPY setup-java-proxy.sh /etc/profile.d/setup-java-proxy.sh
RUN chmod +x /etc/profile.d/setup-java-proxy.sh \
    && echo '. /etc/profile.d/setup-java-proxy.sh' >> /etc/bash.bashrc \
    && echo 'api.version=1.44' > /home/agent/.docker-java.properties

USER agent

# Symlink mounted host .claude dirs to agent's home so tools find them at ~/.claude/
RUN mkdir -p /home/agent/.claude \
    && ln -s /Users/andrew/.claude/skills /home/agent/.claude/skills \
    && ln -s /Users/andrew/.claude/agents /home/agent/.claude/agents

# Preinstall babashka and clojure-tools via mise.
# `mise use --global` installs the tool, sets it as the global default, and creates shims.
# Shims are version-agnostic: if the agent later installs a different version, the same
# shim delegates to whatever version mise resolves from .tool-versions / .mise.toml.
RUN mise use --global babashka@latest clojure@latest \
    && mise reshim
