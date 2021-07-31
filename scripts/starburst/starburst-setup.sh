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

set -xe

mkdir -p /etc/sep/catalog
cd ${STARBURST_HOME} && ln -s /etc/sep etc

cp ${DOWNLOADS}/starburstdata.license /etc/sep/starburstdata.license
cp ${SCRIPTS}/keystore.jks       /etc/sep/keystore.jks

touch ${STARBURST_HOME}/etc/password.db
htpasswd -b -B -C 10 ${STARBURST_HOME}/etc/password.db ddp ddpR0cks!

cat <<EOF > ${STARBURST_HOME}/etc/config.properties
coordinator=true
node-scheduler.include-coordinator=true
node.internal-address=ddp-${NAME}.example.com
http-server.http.port=${HTTP_PORT}
http-server.http.enabled=true
http-server.https.enabled=true
http-server.https.port=${HTTPS_PORT}
http-server.https.keystore.path=etc/keystore.jks
http-server.https.keystore.key=changeit
http-server.authentication.type=PASSWORD,CERTIFICATE
http-server.authentication.allow-insecure-over-http=true
discovery.uri=http://localhost:${HTTP_PORT}
internal-communication.https.required=false
event-listener.config-files=etc/event-logger.properties,etc/atlas-logger.properties
insights.persistence-enabled=true
insights.metrics-persistence-enabled=true
insights.jdbc.url=jdbc:postgresql://ddp-postgres.example.com:5432/event_logger
insights.jdbc.user=starburst_insights 
insights.jdbc.password=ddpR0cks!
insights.authorized-users=.*
access-control.config-files=etc/access-control-system.properties,etc/access-control-ranger.properties
EOF

cat <<EOF > ${STARBURST_HOME}/etc/atlas-logger.properties
event-listener.name=starburst-atlas
atlas.cluster.name=ddp-sales.example.com
atlas.kafka.bootstrap.servers=ddp-kafka.example.com:9092
atlas.server.url=http://ddp-atlas.example.com:21000
atlas.username=admin
atlas.password=ddpR0cks!
EOF

cat <<EOF > ${STARBURST_HOME}/etc/access-control-ranger.properties
access-control.name=ranger
ranger.policy-rest-url=http://ddp-ranger.example.com:6080
ranger.service-name=starburst-enterprise
ranger.username=admin
ranger.password=ddpR0cks!
ranger.policy-refresh-interval=30s
EOF

starburst-ranger-cli service-definition starburst create \
  --properties=${STARBURST_HOME}/etc/access-control-ranger.properties || true

python3 ${SCRIPTS}/ranger-service-starburst-enterprise.py || true

# while ! nc -z ddp-atlas.example.com 21000; do   
#   sleep 1
# done
# starburst-atlas-cli types create --server=http://ddp-atlas.example.com:21000 --user admin --password

cat <<EOF > ${STARBURST_HOME}/etc/access-control-system.properties
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
-Xmx500M
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
-DHADOOP_USER_NAME=hive
EOF

cat <<EOF > ${STARBURST_HOME}/etc/node.properties
node.environment=${NAME}
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/tpcds.properties
connector.name=tpcds
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/global.properties
connector.name=hive
hive.metastore.uri=thrift://ddp-hive.example.com:9083
hive.config.resources=etc/core-site.xml,etc/hdfs-site.xml
hive.security=allow-all
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/cache.properties
connector.name=delta-lake
hive.metastore.uri=thrift://ddp-hive.example.com:9083
hive.config.resources=etc/core-site.xml,etc/hdfs-site.xml
hive.security=allow-all
EOF

cat <<EOF > ${STARBURST_HOME}/etc/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://ddp-hadoop.example.com:9000</value>
  </property>
</configuration>
EOF

cat <<EOF > ${STARBURST_HOME}/etc/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>
EOF

chown -R starburst:starburst ${STARBURST_HOME}/