#!/bin/bash

curl -s -XPUT -d"{
  \"Name\": \"identity-db\",
  \"ID\": \"identity-db\",
  \"Tags\": [ \"postgres\" ],
  \"Address\": \"localhost\",
  \"Port\": 5432,
  \"Check\": {
    \"Name\": \"PostgreSQL TCP on port 5432\",
    \"ID\": \"identity-db\",
    \"Interval\": \"10s\",
    \"TCP\": \"identity-db:5432\",
    \"Timeout\": \"1s\",
    \"Status\": \"passing\"
  }
}" localhost:8500/v1/agent/service/register

curl -s -XPUT -d"{
  \"Name\": \"workspace-db\",
  \"ID\": \"workspace-db\",
  \"Tags\": [ \"postgres\" ],
  \"Address\": \"localhost\",
  \"Port\": 5432,
  \"Check\": {
    \"Name\": \"PostgreSQL TCP on port 5432\",
    \"ID\": \"workspace-db\",
    \"Interval\": \"10s\",
    \"TCP\": \"workspace-db:5432\",
    \"Timeout\": \"1s\",
    \"Status\": \"passing\"
  }
}" localhost:8500/v1/agent/service/register

curl -s -XPUT -d"{
  \"Name\": \"project-db\",
  \"ID\": \"project-db\",
  \"Tags\": [ \"postgres\" ],
  \"Address\": \"localhost\",
  \"Port\": 5432,
  \"Check\": {
    \"Name\": \"PostgreSQL TCP on port 5432\",
    \"ID\": \"project-db\",
    \"Interval\": \"10s\",
    \"TCP\": \"project-db:5432\",
    \"Timeout\": \"1s\",
    \"Status\": \"passing\"
  }
}" localhost:8500/v1/agent/service/register
