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

if [ ! -e ${KAFKA_HOME}/.setupDone ]
then
  touch ${KAFKA_HOME}/.setupDone
  ${KAFKA_SCRIPTS}/kafka-setup.sh
fi

su -c "cd ${KAFKA_HOME} && CLASSPATH=${KAFKA_HOME}/config ./bin/kafka-server-start.sh config/server.properties &" kafka

KAFKA_PID=`ps -ef  | grep -v grep | grep -i "kafka.Kafka config/server.properties" | awk '{print $2}'`

su -c "mkdir -p /opt/kafka/logs" kafka
su -c "touch /opt/kafka/logs/server.log" kafka

# prevent the container from exiting
tail --pid=${KAFKA_PID} -f /opt/kafka/logs/server.log