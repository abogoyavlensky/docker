#!/bin/bash
# setup-java-proxy.sh
# Sourced via BASH_ENV (non-interactive), /etc/profile.d/ (login),
# and /etc/bash.bashrc (interactive) to cover all shell types.
# Imports the Docker sandbox proxy CA into the Java truststore,
# configures Maven proxy, and wraps bb with proxy settings.
PROXY_CA="/usr/local/share/ca-certificates/proxy-ca.crt"

# Skip entirely when not in sandbox proxy environment
if [ ! -f "$PROXY_CA" ]; then
    return 0 2>/dev/null || exit 0
fi

# Configure Maven proxy (once)
if [ -n "$HTTPS_PROXY" ] && [ ! -f /home/agent/.m2/settings.xml ]; then
    PROXY_HOST="$(echo "$HTTPS_PROXY" | sed 's|http://||' | cut -d: -f1)"
    PROXY_PORT="$(echo "$HTTPS_PROXY" | sed 's|http://||' | cut -d: -f2)"
    mkdir -p /home/agent/.m2
    cat > /home/agent/.m2/settings.xml << EOF
<settings>
  <proxies>
    <proxy>
      <id>sandbox-https</id>
      <active>true</active>
      <protocol>https</protocol>
      <host>${PROXY_HOST}</host>
      <port>${PROXY_PORT}</port>
      <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
    </proxy>
    <proxy>
      <id>sandbox-http</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>${PROXY_HOST}</host>
      <port>${PROXY_PORT}</port>
      <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
EOF
fi

# Import proxy CA into Java truststore (re-checks each time until Java exists)
JAVA_PROXY_MARKER="/home/agent/.java-proxy-ca-imported"
if [ ! -f "$JAVA_PROXY_MARKER" ]; then
    JAVA_CACERTS="$(find /home/agent/.local/share/mise/installs/java -name cacerts 2>/dev/null | head -1)"
    if [ -n "$JAVA_CACERTS" ]; then
        keytool -importcert -trustcacerts \
            -alias docker-sandbox-proxy-ca \
            -file "$PROXY_CA" \
            -keystore "$JAVA_CACERTS" \
            -storepass changeit \
            -noprompt 2>/dev/null
        touch "$JAVA_PROXY_MARKER"
    fi
fi

# Wrap bb (babashka) to pass proxy and SSL settings to the GraalVM native image.
# bb doesn't read HTTPS_PROXY or Maven settings — needs explicit -D properties.
if [ -n "$HTTPS_PROXY" ] && ! declare -f bb >/dev/null 2>&1; then
    bb() {
        local bb_opts=""
        local cacerts
        cacerts="$(find /home/agent/.local/share/mise/installs/java -name cacerts -path '*/lib/security/*' 2>/dev/null | head -1)"
        if [ -n "$cacerts" ] && [ -f "$cacerts" ]; then
            bb_opts="-Djavax.net.ssl.trustStore=$cacerts"
        fi
        local proxy_host proxy_port
        proxy_host="$(echo "$HTTPS_PROXY" | sed 's|http://||' | cut -d: -f1)"
        proxy_port="$(echo "$HTTPS_PROXY" | sed 's|http://||' | cut -d: -f2)"
        command bb $bb_opts \
            "-Dhttp.proxyHost=$proxy_host" \
            "-Dhttp.proxyPort=$proxy_port" \
            "-Dhttps.proxyHost=$proxy_host" \
            "-Dhttps.proxyPort=$proxy_port" \
            "-Dhttp.nonProxyHosts=localhost|127.0.0.1" \
            "$@"
    }
fi
