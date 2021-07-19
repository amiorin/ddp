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

echo "export JAVA_HOME=${JAVA_HOME}" >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

cat <<EOF > ${HADOOP_HOME}/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://ddp-hadoop.example.com:9000</value>
  </property>
</configuration>
EOF

cp ${HIVE_SCRIPTS}/hive-site.xml ${HIVE_HOME}/conf/hive-site.xml
cp ${HIVE_SCRIPTS}/hive-site.xml ${HIVE_HOME}/conf/hiveserver2-site.xml
su -c "${HIVE_HOME}/bin/schematool -dbType postgres -initSchema" hive || true

mkdir -p /opt/hive/logs
chown -R hive:hadoop /opt/hive/
chmod g+w /opt/hive/logs

cd ${RANGER_HOME}/ranger-hive-plugin
./enable-hive-plugin.sh