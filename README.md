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
   Make sure to configure docker with at least 8gb of memory.

1. Set this folder as your working directory.

1. Build and copy the Apache Ranger files from https://github.com/apache/ranger/tree/master/dev-support/ranger-docker to ./dist/ranger
    
       ranger-3.0.0-SNAPSHOT-admin.tar.gz
       ranger-3.0.0-SNAPSHOT-atlas-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-elasticsearch-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-hbase-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-hdfs-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-hive-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-kafka-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-kms.tar.gz
       ranger-3.0.0-SNAPSHOT-knox-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-kylin-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-migration-util.tar.gz
       ranger-3.0.0-SNAPSHOT-ozone-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-presto-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-ranger-tools.tar.gz
       ranger-3.0.0-SNAPSHOT-schema-registry-plugin.jar
       ranger-3.0.0-SNAPSHOT-solr-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-solr_audit_conf.tar.gz
       ranger-3.0.0-SNAPSHOT-solr_audit_conf.zip
       ranger-3.0.0-SNAPSHOT-sqoop-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-src.tar.gz
       ranger-3.0.0-SNAPSHOT-storm-plugin.tar.gz
       ranger-3.0.0-SNAPSHOT-tagsync.tar.gz
       ranger-3.0.0-SNAPSHOT-usersync.tar.gz
       ranger-3.0.0-SNAPSHOT-yarn-plugin.tar.gz

1. Build and copy the Apache Atlas files from https://github.com/apache/atlas/tree/master/dev-support/atlas-docker to ./dist/atlas

       apache-atlas-3.0.0-SNAPSHOT-hbase-hook.tar.gz
       apache-atlas-3.0.0-SNAPSHOT-hive-hook.tar.gz
       apache-atlas-3.0.0-SNAPSHOT-server.tar.gz

1. Update environment variables in .env file, if necessary

1. Request a trial license to Starburst https://www.starburst.io/

1. Save the Starburst license in ```./downloads/starburstdata.license```

1. Execute following command to download necessary archives to setup Atlas/Ranger/HDFS/Hive/HBase/Kafka/Starburst services:

       ./download-archives.sh

1. Some files needs to be copied manually. The content of ```./downloads``` must be like this:

       apache-hive-3.1.2-bin.tar.gz
       hadoop-3.1.0.tar.gz
       hadoop-3.3.1.tar.gz
       hbase-2.3.3-bin.tar.gz
       kafka_2.12-2.8.0.tgz
       postgresql-42.2.16.jre7.jar
       starburst-enterprise-356-e.5.tar.gz
       starburst-ranger-cli-356-e.5-executable.jar
       starburst-ranger-plugin-2.0.51.jar
       starburstdata.license
       trino-jdbc-356-e.5.jar
       zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb

1. Execute following command to start Starburst Trino:

       docker-compose up

1. Starburst Trino can be accessed at https://localhost/ui (ddp/ddpR0cks!) or https://localhost/ui/insights
   Paste chrome://flags/#allow-insecure-localhost to fix the certificate problem.

1. Starburst Trino cli ```trino-cli --server=https://localhost --insecure --password --user ddp``` (ddp/ddpR0cks!)

## Web
* Starburst https://localhost/ui
* Starburst https://localhost/ui/insights
* Starburst http://localhost:8080/ui
* Starburst http://localhost:8080/ui/insights
* Namenode http://localhost:9870
* Resource Manager http://localhost:8088
* HBase http://localhost:16010
* Atlas http://localhost:21000
* Hive http://localhost:10002
* Ranger http://localhost:6080

## Misc
```sql
create table hive.default.item as select * from tpcds.tiny.item
```

```sh
bin/kafka-topics.sh --list --bootstrap-server ddp-kafka.example.com:9092
bin/kafka-console-consumer.sh --topic ATLAS_HOOK --from-beginning --bootstrap-server ddp-kafka.example.com:9092 | jq .
bin/kafka-console-consumer.sh --topic ATLAS_ENTITIES --from-beginning --bootstrap-server ddp-kafka.example.com:9092 | jq .
```

```sh
# Fast container rebuild
docker-compose build ddp-base && \
docker-compose up -d && \
docker-compose logs -f
# rebuild ddp-atlas only
export SERVICE=ddp-kafka && \
docker-compose stop $SERVICE && \
docker-compose build --no-cache $SERVICE && \
docker-compose up -d --no-deps && \
docker-compose logs -f $SERVICE
# shell in the service under developement
docker exec -it --privileged $SERVICE bash
# shutdown and clean up
docker-compose down && \
docker system prune -af
```

```sql
-- before starting ranger after a build step
DROP DATABASE ranger;
CREATE DATABASE ranger;
GRANT ALL PRIVILEGES ON DATABASE ranger TO rangeradmin;
```

```bash
# Starburst Atlas integration
export ATLAS_URL=http://ddp-atlas.example.com:21000
export STARBURST_HOST=ddp-starburst.example.com:8080
starburst-atlas-cli types create --server=${ATLAS_URL} --user admin --password
starburst-atlas-cli cluster register --server=${ATLAS_URL} --user=admin --password --cluster-name=ddp-starburst
starburst-atlas-cli catalog register --server=${ATLAS_URL} \
--user admin --password \
--cluster-name ddp-starburst \
--catalog tpcds \
--starburst-jdbc-url "jdbc:trino://${STARBURST_HOST}?user=ddp"


```

```
CREATE TABLE hive.default.item3 (
   i_item_sk bigint,
   i_item_id char(16),
   i_rec_start_date date,
   i_rec_end_date date,
   i_item_desc varchar(200),
   i_current_price decimal(7, 2),
   i_wholesale_cost decimal(7, 2),
   i_brand_id integer,
   i_brand char(50),
   i_class_id integer,
   i_class char(50),
   i_category_id integer,
   i_category char(50),
   i_manufact_id integer,
   i_manufact char(50),
   i_size char(20),
   i_formulation char(20),
   i_color char(20),
   i_units char(10),
   i_container char(10),
   i_manager_id integer
)
WITH (
   format = 'ORC',
   external_location = 'hdfs:///user/hive/warehouse/item'
);
   i_product_name char(50)

CREATE OR REPLACE VIEW hive.default.v_item3 SECURITY INVOKER AS select * from hive.default.item3;
```

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