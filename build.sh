#!/bin/bash

set -x

## Sets the name of the database
DBNAME=${1:-rdtd}


# Drops existing Stardog databaase
stardog-admin db drop $DBNAME || :

## Creates a Stardog database
stardog-admin db create -n $DBNAME

## Imports Namespaces
stardog namespace import $DBNAME ./data/namespace.ttl

## Adds the data.
stardog data add $DBNAME ./data/logical-backup.ttl.gz

## Verifies the number of triples in the default graph
stardog data size --exact router

## Runs Spark
spark-submit --master local[*] --files router.properties stardog-spark-connector-1.0.1.jar router.properties

## Verifies the number of triples in the default graph
stardog data size --exact router

## Verifies Output. The Spark Connector output the results that Spark produced into Stardog
stardog query $DBNAME ./query-files/pageRankRoundedScore.sparql

## Runs all tests
stardog test run ./data/test.ttl
