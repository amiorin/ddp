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
cd ${CACHE_HOME} && ln -s /etc/sep etc

cp ${DOWNLOADS}/starburstdata.license /etc/sep/starburstdata.license

cat <<EOF > ${CACHE_HOME}/etc/config.properties
service-database.user=cache
service-database.password=ddpR0cks!
service-database.jdbc-url=jdbc:postgresql://ddp-postgres.example.com/redirections
starburst.user=ddp
starburst.jdbc-url=jdbc:trino://ddp-starburst.example.com:8080
rules.file=etc/rules.json
# it requires 358-e
# type-mapping=FILE
# type-mapping.file=etc/type-mapping.json
EOF

cat <<EOF > ${CACHE_HOME}/etc/rules.json
{
  "rules": []
}
EOF

# You can find it in the manual starting from Starburst 358-e.
cat <<EOF > ${CACHE_HOME}/etc/type-mapping.json
{
  "rules": {
    "delta": {
      "timestamp(0)": "timestamp(3)",
      "timestamp(1)": "timestamp(3)",
      "timestamp(2)": "timestamp(3)",
      "timestamp(4)": "timestamp(3)",
      "timestamp(5)": "timestamp(3)",
      "timestamp(6)": "timestamp(3)"
    }
    "hive": {
      "timestamp(0)": "timestamp(3)",
      "timestamp(1)": "timestamp(3)",
      "timestamp(2)": "timestamp(3)",
      "timestamp(4)": "timestamp(3)",
      "timestamp(5)": "timestamp(3)",
      "timestamp(6)": "timestamp(3)"
    }
  }
}
EOF

cat <<EOF > ${CACHE_HOME}/etc/jvm.config
-server
-Xmx512M
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
EOF

chown -R starburst:starburst ${CACHE_HOME}/