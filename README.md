# Kepler 16b

[![CI](https://github.com/opencaesar/kepler16b-example/actions/workflows/ci.yml/badge.svg)](https://github.com/opencaesar/kepler16b-example/actions/workflows/ci.yml)
[![Pages](https://img.shields.io/badge/Pages-HTML-blue)](http://opencaesar.github.io/kepler16b-example/) 

This is an example OML project for a hypothetical mission called Kepler 16b. For details, check this [tutorial](http://www.opencaesar.io/oml-tutorials/#tutorial2).

## Clone
```
  git clone https://github.com/opencaesar/kepler16b-example.git
  cd kepler16b-example
```

## Clean
```
./gradlew clean
```

## Build
```
./gradlew build
```

## Start Fuseki Server
```
./gradlew startFuseki
```

## Stop Fuseki Server
```
./gradlew stopFuseki
```

## Load Dataset to Fuseki
```
./gradlew load
```

## Save Dataset from Fuseki
```
./gradlew save
```

## Run SPARQL Queries
```
./gradlew query
```
