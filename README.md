<!---
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

## Overview
The Docker files in this folder create docker images and run them to build Apache Ranger and Atlas, package Starburst Trino, and deploy all them together with the dependent services in containers.

## Usage
1. Ensure that you have recent version of Docker installed from [docker.io](http://www.docker.io) (as of this writing: Engine 20.10.5, Compose 1.28.5).
   Make sure to configure docker with at least 6gb of memory.

2. Set this folder as your working directory.

3. Update environment variables in .env file, if necessary

4. Execute following command to download necessary archives to setup Atlas/Ranger/HDFS/Hive/HBase/Kafka/Starburst services:
     ./download-archives.sh

5. Build and start Starburst Trino in containers using docker-compose

   5.1. Execute following command to start Starburst Trino:

        docker-compose -f docker-compose.ddp-base.yml -f docker-compose.ddp-starburst.yml up

6. Starburst Trino can be accessed at https://localhost (ddp/ddpR0cks!).
   Paste chrome://flags/#allow-insecure-localhost to fix the certificate problem.

## Containers
* Starburst Trino
* Atlas
* Ranger
* Postgres
* Kafka
* Solr
* Hadoop
* HBase
* Zookeeper

## Credit
This project is reusing most of the code of 
* https://github.com/apache/atlas/tree/master/dev-support/atlas-docker
* https://github.com/apache/ranger/tree/master/dev-support/ranger-docker
