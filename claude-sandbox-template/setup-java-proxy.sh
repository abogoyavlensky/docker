#!/bin/bash                                                     
# setup-java-proxy.sh
# Sourced via /etc/profile.d/ on login shells.
# Imports the Docker sandbox proxy CA into the Java truststore and
# configures Maven to route through the proxy.
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
