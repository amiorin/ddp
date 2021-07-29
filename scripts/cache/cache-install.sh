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

mkdir -p $CACHE_HOME
tar zxf ${DOWNLOADS}/starburst-cache-service-356-e.5.tar.gz --directory=${CACHE_HOME} --strip 1
dpkg -i ${DOWNLOADS}/zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb
cp ${DOWNLOADS}/starburst-cache-cli-356-e.5-executable.jar /usr/local/bin/starburst-cache-cli
chown -R starburst:starburst ${CACHE_HOME}/