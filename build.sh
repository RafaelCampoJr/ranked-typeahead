#!/bin/bash

set -x

## Sets the name of the database
DBNAME=${1:-rdtd}


# Drops existing Stardog databaase
stardog-admin db drop $DBNAME || :

## Creates a Stardog database
stardog-admin db create -n $DBNAME -c data/database.properties

## Imports Namespaces
stardog namespace import $DBNAME ./data/namespace.ttl

## Adds the data.
stardog data add $DBNAME ./data/person.ttl

## Verifies the number of triples in the default graph
stardog data size --exact $DBNAME 

## Runs tests before access
stardog test run ./data/test-before.ttl

## Logs the access of the resource
stardog query rdtd query-files/add-timestamp.sparql

## Runs tests after access
stardog test run ./data/test-after.ttl