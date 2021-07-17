#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

mkdir -p /etc/sep/catalog
cd ${STARBURST_HOME} && ln -s /etc/sep etc

cp ${STARBURST_DIST}/starburstdata.license /etc/sep/starburstdata.license
cp ${STARBURST_SCRIPTS}/keystore.jks       /etc/sep/keystore.jks

touch ${STARBURST_HOME}/etc/password.db
htpasswd -b -B -C 10 ${STARBURST_HOME}/etc/password.db ddp ddpR0cks!

cat <<EOF > ${STARBURST_HOME}/etc/config.properties
coordinator=true
node-scheduler.include-coordinator=true
node.internal-address=ddp-starburst.example.com
http-server.http.port=8080
http-server.http.enabled=false
http-server.https.enabled=true
http-server.https.port=443
http-server.https.keystore.path=etc/keystore.jks
http-server.https.keystore.key=changeit
http-server.authentication.type=PASSWORD,CERTIFICATE
discovery-server.enabled=true
discovery.uri=https://ddp-starburst.example.com
internal-communication.https.required=true
internal-communication.https.keystore.path=etc/keystore.jks
internal-communication.https.keystore.key=changeit
internal-communication.shared-secret=NjqD4JuanYnfMCgpKwdwQP8zCMVWPA8mu9kU+C6A7++3dhtzPOI8JyAWRvPoIHchiI5x1FL7KcU10N+Z1IZX2f9pbrxoGhWsAfG6/08WgnwfzSM4rb2+ITjDpa8V/Xw2c3msWw0/2wmVCHP+uqMYF3MQp8LMAp9qVALPMI10yM/sianIIKBDyGSIvqjR+9xqEqkCI+p5yC98HwEgOsOdp4xa/5QbAzT0v2VaSq34H1WbvMcm4RwmFW19mn5vXRDsZymKY2V4TRWOZ+Rraus0bYgKlZ6YPo8BWa+yNkpVdtJFVN3X6mx2jQmE0ZLFqc9lPPj7WauqM8ck3LTz5sSo/bRtkF3RtDzgJZbJjsscV4uGSmsEtfE/UlFaWiciEbODOUc45qmosD4cJhlUce5Ji3rQnlNyGnhY81yXpMqTxD3QXGon9c4zatYAhRA7DF1qR7Z7ARvcJCqTCVNIfUf5YS8tdM1UHgt+Pa59TaJYLDuo5Wxf+L2qt3CkWOrGEs7M424AKlxAsqKrhbKC7KbkI2x1On+vjzbYGhAVK/9bJYKGVzRONDgGym/0i6zgxMjqaQ37NdP2HTnMWWvpUawNXIFVlDl/LrNfsJToUFtT5X5rheqXnIly6On8qkW3cGiFUGjUQ+7u7Ys+fl9SC+I3mZ2KwHtq0Z52aGoU+HiQQuQ=
query.max-memory=5GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
event-listener.config-files=etc/event-logger.properties
insights.persistence-enabled=true
insights.metrics-persistence-enabled=true
insights.jdbc.url=jdbc:postgresql://ddp-postgres.example.com:5432/event_logger
insights.jdbc.user=starburst_insights 
insights.jdbc.password=ddpR0cks!
insights.authorized-users=.*
access-control.config-files=etc/access-control-1.properties
EOF

cat <<EOF > ${STARBURST_HOME}/etc/access-control-1.properties
access-control.name=allow-all
EOF

cat <<EOF > ${STARBURST_HOME}/etc/event-logger.properties
event-listener.name=event-logger
jdbc.url=jdbc:postgresql://ddp-postgres.example.com:5432/event_logger
jdbc.user=starburst_insights 
jdbc.password=ddpR0cks!
EOF

cat <<EOF > ${STARBURST_HOME}/etc/password-authenticator.properties
password-authenticator.name=file
file.password-file=etc/password.db
EOF

cat <<EOF > ${STARBURST_HOME}/etc/jvm.config
-server
-Xmx16G
-XX:-UseBiasedLocking
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
EOF

cat <<EOF > ${STARBURST_HOME}/etc/node.properties
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/tpcds.properties
connector.name=tpcds
EOF

chown -R starburst:starburst ${STARBURST_HOME}/