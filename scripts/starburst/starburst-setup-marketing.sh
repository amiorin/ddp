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

cat <<EOF > ${STARBURST_HOME}/etc/catalog/marketing.properties
connector.name=hive
hive.metastore=glue
hive.security=allow-all
hive.metastore.glue.region=eu-central-1
hive.metastore.glue.catalogid=${AWS_ACCOUNT}
hive.metastore.glue.default-warehouse-dir=${AWS_BUCKET}
redirection.config-source=SERVICE
cache-service.uri=http://ddp-cache2.example.com:8180
EOF

cat <<EOF > ${STARBURST_HOME}/etc/catalog/starburst.properties
connector.name=stargate
connection-url=jdbc:trino://ddp-starburst.example.com:443/starburst
connection-user=ddp
connection-password=ddpR0cks!
ssl.enabled=true
ssl.truststore.path=etc/keystore.jks
ssl.truststore.password=changeit
redirection.config-source=SERVICE
cache-service.uri=http://ddp-cache2.example.com:8180
EOF