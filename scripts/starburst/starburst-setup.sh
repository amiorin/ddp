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

cp ${STARBURST_DIST}/starburstdata.license /etc/sep/starburstdata.license
cp ${STARBURST_SCRIPTS}/keystore.jks       /etc/sep/keystore.jks

touch ${STARBURST_HOME}/etc/password.db
htpasswd -b -B -C 10 ${STARBURST_HOME}/etc/password.db ddp ddpR0cks!

cat <<EOF > ${STARBURST_HOME}/etc/config.properties
coordinator=true
node-scheduler.include-coordinator=true
node.internal-address=ddp-starburst.example.com
http-server.http.port=8080
http-server.http.enabled=true
http-server.https.enabled=true
http-server.https.port=443
http-server.https.keystore.path=etc/keystore.jks
http-server.https.keystore.key=changeit
http-server.authentication.type=PASSWORD,CERTIFICATE
http-server.authentication.allow-insecure-over-http=true
discovery-server.enabled=true
discovery.uri=http://localhost:8080
internal-communication.https.required=false
query.max-memory=5GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
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
atlas.cluster.name=ddp-starburst.example.com
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

python3 ${STARBURST_SCRIPTS}/ranger-service-starburst-enterprise.py || true

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
-DHADOOP_USER_NAME=hive
EOF

cat <<EOF > ${STARBURST_HOME}/etc/node.properties
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/tpcds.properties
connector.name=tpcds
EOF

for i in event_logger hive ranger redirections
do
cat <<EOF > ${STARBURST_HOME}/etc/catalog/postgres_${i}.properties
connector.name=postgresql
connection-url=jdbc:postgresql://ddp-postgres.example.com:5432/${i}
connection-user=postgres
connection-password=ddpR0cks!
redirection.config-source=SERVICE
cache-service.uri=http://ddp-cache.example.com:8180
EOF
done

cat <<EOF > ${STARBURST_HOME}/etc/catalog/hive.properties
connector.name=hive-hadoop2
hive.metastore.uri=thrift://ddp-hive.example.com:9083
hive.config.resources=etc/core-site.xml,etc/hdfs-site.xml
hive.security=allow-all
redirection.config-source=SERVICE
cache-service.uri=http://ddp-cache.example.com:8180
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/delta.properties
connector.name=delta-lake
hive.metastore.uri=thrift://ddp-hive.example.com:9083
hive.config.resources=etc/core-site.xml,etc/hdfs-site.xml
hive.security=allow-all
# not supported yet
# delta.hive-catalog-name=hive
# redirection.config-source=SERVICE
# cache-service.uri=http://ddp-cache.example.com:8180
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