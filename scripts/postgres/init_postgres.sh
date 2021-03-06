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

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER starburst_insights WITH PASSWORD 'ddpR0cks!';
    CREATE DATABASE event_logger;
    GRANT ALL PRIVILEGES ON DATABASE event_logger TO starburst_insights;

    CREATE USER hive WITH PASSWORD 'ddpR0cks!';
    CREATE DATABASE hive;
    GRANT ALL PRIVILEGES ON DATABASE hive TO hive;

    CREATE USER rangeradmin WITH PASSWORD 'ddpR0cks!';
    CREATE DATABASE ranger;
    GRANT ALL PRIVILEGES ON DATABASE ranger TO rangeradmin;

    CREATE USER cache WITH PASSWORD 'ddpR0cks!';
    CREATE DATABASE redirections;
    GRANT ALL PRIVILEGES ON DATABASE redirections TO cache;

    CREATE DATABASE redirections2;
    GRANT ALL PRIVILEGES ON DATABASE redirections2 TO cache;

    CREATE USER trino WITH PASSWORD 'ddpR0cks!';
    CREATE DATABASE marketing;
    GRANT ALL PRIVILEGES ON DATABASE marketing TO trino;
    CREATE DATABASE sales;
    GRANT ALL PRIVILEGES ON DATABASE sales TO trino;
EOSQL