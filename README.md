# Kepler 16b

[![CI](https://github.com/melaasar/kepler16b/actions/workflows/ci.yml/badge.svg)](https://github.com/melaasar/kepler16b/actions/workflows/ci.yml)
[![Pages](https://img.shields.io/badge/Pages-HTML-blue)](http://melaasar.github.io/kepler16b/) 

This is an example Oml project for a hypothetical mission called Kepler 16b.

## Clone

Clone this repo to your machine
   ```
     git clone git@github.com:melaasar/kepler16b.git
   ```
## Build
   
Build the repo by invoking the gradle build script
   ```
   cd kepler16b
   ./gradlew build
   ```
   >NOTE: If you are on Windows, replace ./gradlew with gradlew.bat (also in the instructions below)

## Analyze

Start Fuseki Server
   ```
   ./gradlew startFuseki
   ```
   
Run the provided sparql queries
   ```
   ./gradlew query
   ```
   
Stop Fuseki Server
   ```
   ./gradlew stopFuseki
   ```

Generate the web views
   ```
   ./gradlew render
   ```
   
Render the document
   ```
   ./gradlew bikeshed
   ```
