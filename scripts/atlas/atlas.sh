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

if [ ! -e ${ATLAS_HOME}/.setupDone ]
then
  touch ${ATLAS_HOME}/.setupDone

  encryptedPwd=$(${ATLAS_HOME}/bin/cputil.py -g -u admin -p atlasR0cks! -s)

  echo "admin=ADMIN::${encryptedPwd}" > ${ATLAS_HOME}/conf/users-credentials.properties

  sed -i "s/atlas.graph.storage.hostname=.*$/atlas.graph.storage.hostname=ddp-zookeeper.example.com:2181/"             /opt/atlas/conf/atlas-application.properties
  sed -i "s/atlas.audit.hbase.zookeeper.quorum=.*$/atlas.audit.hbase.zookeeper.quorum=ddp-zookeeper.example.com:2181/" /opt/atlas/conf/atlas-application.properties

  sed -i "s/^atlas.graph.index.search.solr.mode=cloud/# atlas.graph.index.search.solr.mode=cloud/"                                              /opt/atlas/conf/atlas-application.properties
  sed -i "s/^# *atlas.graph.index.search.solr.mode=http/atlas.graph.index.search.solr.mode=http/"                                               /opt/atlas/conf/atlas-application.properties
  sed -i "s/^.*atlas.graph.index.search.solr.http-urls=.*$/atlas.graph.index.search.solr.http-urls=http:\/\/ddp-solr.example.com:8983\/solr/" /opt/atlas/conf/atlas-application.properties

  sed -i "s/atlas.notification.embedded=.*$/atlas.notification.embedded=false/"                            /opt/atlas/conf/atlas-application.properties
  sed -i "s/atlas.kafka.zookeeper.connect=.*$/atlas.kafka.zookeeper.connect=ddp-zookeeper.example.com:2181/"    /opt/atlas/conf/atlas-application.properties
  sed -i "s/atlas.kafka.bootstrap.servers=.*$/atlas.kafka.bootstrap.servers=ddp-kafka.example.com:9092/" /opt/atlas/conf/atlas-application.properties

  chown -R atlas:atlas ${ATLAS_HOME}/
fi

su -c "cd ${ATLAS_HOME}/bin && ./atlas_start.py" atlas
ATLAS_PID=`ps -ef  | grep -v grep | grep -i "org.apache.atlas.Atlas" | awk '{print $2}'`

# prevent the container from exiting
tail --pid=$ATLAS_PID -f /dev/null