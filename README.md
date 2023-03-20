# Kepler 16b

[![CI](https://github.com/opencaesar/kepler16b-example/actions/workflows/ci.yml/badge.svg)](https://github.com/opencaesar/kepler16b-example/actions/workflows/ci.yml)
[![Pages](https://img.shields.io/badge/Pages-HTML-blue)](http://opencaesar.github.io/kepler16b-example/) 

This is an example Oml project for a hypothetical mission called Kepler 16b.

## Clone

Clone this repo to your machine
   ```
     git clone git@github.com:opencaesar/kepler16b-example.git
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

# Jupyter Notebook
For MacOS users:
1. sudo mkdir /usr/local/share/jupyter
2. sudo chown -R <macos_username> /usr/local/share/jupyter
3. Run `./gradlew query` 
4. Run the section of the notebook under `1. Objectives`
