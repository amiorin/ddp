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

#
# Downloads HDFS/Hive/HBase/Kafka/.. archives to a local cache directory.
# The downloaded archives will be used while building docker images that
# run these services
#


#
# source .env file to get versions to download
#
source .env


downloadIfNotPresent() {
  local dirName=$1
  local fileName=$2
  local urlBase=$3

  if [ ! -f "${dirName}/${fileName}" ]
  then
    echo "downloading ${urlBase}/${fileName}.."

    curl -L ${urlBase}/${fileName} --output ${dirName}/${fileName}
  else
    echo "file already in cache: ${fileName}"
  fi
}

downloadIfNotPresent downloads hadoop-${HADOOP_VERSION}.tar.gz                  https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}
downloadIfNotPresent downloads zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb       https://cdn.azul.com/zulu/bin
downloadIfNotPresent downloads starburst-enterprise-${STARBURST_VERSION}.tar.gz https://s3.us-east-2.amazonaws.com/software.starburstdata.net/359e/${STARBURST_VERSION}
downloadIfNotPresent downloads kafka_2.12-${KAFKA_VERSION}.tgz                  https://archive.apache.org/dist/kafka/${KAFKA_VERSION}
downloadIfNotPresent downloads apache-hive-${HIVE_VERSION}-bin.tar.gz           https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}
downloadIfNotPresent downloads hadoop-${HIVE_HADOOP_VERSION}.tar.gz             https://archive.apache.org/dist/hadoop/common/hadoop-${HIVE_HADOOP_VERSION}
downloadIfNotPresent downloads hbase-${HBASE_VERSION}-bin.tar.gz                https://archive.apache.org/dist/hbase/${HBASE_VERSION}
downloadIfNotPresent downloads postgresql-42.2.16.jre7.jar                      https://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/42.2.16.jre7
# needed by ranger-atlas-plugin
downloadIfNotPresent downloads commons-compress-1.8.1.jar                       https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.8.1
downloadIfNotPresent downloads commons-lang3-3.3.2.jar                          https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.3.2
# atlas
downloadIfNotPresent dist/atlas apache-atlas-${ATLAS_VERSION}-hbase-hook.tar.gz https://github.com/amiorin/ddp/releases/download/1.0
downloadIfNotPresent dist/atlas apache-atlas-${ATLAS_VERSION}-hive-hook.tar.gz  https://github.com/amiorin/ddp/releases/download/1.0
downloadIfNotPresent dist/atlas apache-atlas-${ATLAS_VERSION}-server.tar.gz     https://github.com/amiorin/ddp/releases/download/1.0
# ranger
downloadIfNotPresent dist/ranger ranger-${RANGER_VERSION}-admin.tar.gz        https://github.com/amiorin/ddp/releases/download/1.0
downloadIfNotPresent dist/ranger ranger-${RANGER_VERSION}-atlas-plugin.tar.gz https://github.com/amiorin/ddp/releases/download/1.0
downloadIfNotPresent dist/ranger ranger-${RANGER_VERSION}-hive-plugin.tar.gz  https://github.com/amiorin/ddp/releases/download/1.0