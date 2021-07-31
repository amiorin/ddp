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
Docker Data Platform is a Query Fabric sandbox that runs on you computer. A Query Fabric is reusing the ideas of Data Lake, Query Federation, and Data Mesh.
* All the structured data of a company secured in one place without data movement and queryable with one SQL at scale and forever.
   * **Structured.** The Query Fabric is not a Data Lake but it leverages the technology of the Data Lakes like S3 or HDFS.
   * **Secured at scale.** Scalable security is achieved with RBAC and ABAC. Users are not granted SELECT to the single table but to the attribute and the attribute is associated with the columns. Column lineage allows these attributes to propagate automatically.
   * **Data movement at scale.** Data movement is an anti-pattern in data. Usually metadata is lost during the data movement. Query Fabric advocate for a semantic layer declined per domain made with views. Table redirections and local caching provide the performance without creating duplicates in the catalog of assets.
   * **One SQL.** The underline SQL dialects of the different databases is creating friction. A lot of cleaning of data is done with SQL views that are not portable. In a Query Fabric there is only one SQL and all views are defined in one language.
   * **Forever.** SQL is almost 50 years old but every company has legacy databases. Using a Query Fabric on top of the physical databases will make the phase out of legacy databases much easier because it doesn't require a migration of the SQL code written by users.

## Usage
1. Ensure that you have recent version of Docker installed from [docker.io](http://www.docker.io) (as of this writing: Engine 20.10.5, Compose 1.28.5).
   Make sure to configure docker with at least 8gb of memory. Increase the Docker memory if see containers killed.

1. Set this folder as your working directory.

1. Create 2 AWS accounts with 2 buckets.

1. Create an ```.env``` file starting from ```.env.template```. You need two AWS accounts and you need to setup the credentials in two different profiles.

1. Request a trial license to Starburst https://www.starburst.io/

1. Save the Starburst license in ```./downloads/starburstdata.license```

1. Execute following command to download necessary archives to setup Atlas/Ranger/HDFS/Hive/HBase/Kafka/Starburst services:

       ./download-archives.sh

1. Some files needs to be copied manually. The content of ```./downloads``` must be like this:

       apache-hive-3.1.2-bin.tar.gz
       commons-compress-1.8.1.jar
       commons-lang3-3.3.2.jar
       hadoop-3.1.0.tar.gz
       hadoop-3.3.1.tar.gz
       hbase-2.3.3-bin.tar.gz
       kafka_2.12-2.8.0.tgz
       postgresql-42.2.16.jre7.jar
       starburst-atlas-cli-359-e-executable.jar
       starburst-cache-cli-359-e-executable.jar
       starburst-cache-service-359-e.tar.gz
       starburst-enterprise-359-e.tar.gz
       starburst-ranger-cli-359-e-executable.jar
       starburst-ranger-plugin-2.1.0-e.7.jar
       starburstdata.license
       trino-cli-359-executable.jar
       trino-jdbc-359-e.jar
       zulu11.48.21-ca-jdk11.0.11-linux_amd64.deb

1. Execute following command to start Starburst Trino:

       docker-compose build ddp-base && docker-compose up

1. Starburst Trino can be accessed at https://localhost/ui (ddp/ddpR0cks!) or https://localhost/ui/insights
   Paste chrome://flags/#allow-insecure-localhost to fix the certificate problem.

1. Starburst Trino cli ```trino-cli --server=https://localhost --insecure --password --user ddp``` (ddp/ddpR0cks!)

## Web
* Generic domain
   * Starburst https://localhost/ui
   * Starburst https://localhost/ui/insights
   * Starburst http://localhost:8080/ui
   * Starburst http://localhost:8080/ui/insights
* Marketing domain
   * Starburst https://localhost:1443/ui
   * Starburst https://localhost:1443/ui/insights
   * Starburst http://localhost:18080/ui
   * Starburst http://localhost:18080/ui/insights
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
docker-compose build ddp-base && docker-compose up
# rebuild ddp-starburst only
docker-compose up --no-deps --force-recreate ddp-starburst
# shell in the service under developement
docker exec -it --privileged $SERVICE bash
# shutdown and clean up
docker-compose down && docker system prune -af
```

```sql
-- before starting ranger after a build step
DROP DATABASE ranger;
CREATE DATABASE ranger;
GRANT ALL PRIVILEGES ON DATABASE ranger TO rangeradmin;

-- cache2
DROP DATABASE redirections2;
CREATE DATABASE redirections2;
GRANT ALL PRIVILEGES ON DATABASE redirections2 TO cache;
```

```bash
# Starburst Atlas integration
export ATLAS_URL=http://ddp-atlas.example.com:21000
export STARBURST_HOST=ddp-starburst.example.com:8080
starburst-atlas-cli types create --server=${ATLAS_URL} --user admin --password
starburst-atlas-cli cluster register --server=${ATLAS_URL} --user=admin --password --cluster-name=ddp-starburst.example.com
starburst-atlas-cli catalog register --server=${ATLAS_URL} \
--user admin --password \
--cluster-name ddp-starburst \
--catalog tpcds \
--starburst-jdbc-url "jdbc:trino://${STARBURST_HOST}?user=ddp"
```

```sql
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

```sh
# starburst cache
docker exec -it --privileged ddp-cache bash

starburst-cache-cli cache \
  --cache-ttl 1h \
  --source postgres_event_logger.public.query_tables \
  --target-catalog hive \
  --target-schema default

starburst-cache-cli cache \
  --cache-ttl 1h \
  --source postgres_event_logger.public.cluster_metrics \
  --target-catalog delta \
  --target-schema default

starburst-cache-cli cache \
  --cache-ttl 1h \
  --source marketing.default.item \
  --target-catalog global \
  --target-schema default

starburst-cache-cli cache \
  --cache-ttl 1h \
  --source starburst.default.item \
  --target-catalog global \
  --target-schema default
```

```sql
CREATE OR REPLACE VIEW global.starburst.item SECURITY INVOKER AS SELECT * FROM starburst.default.item
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