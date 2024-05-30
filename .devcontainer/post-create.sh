#!/bin/sh

conda env create --file environment.yml

# these two commands dont work well
#conda init
#conda activate py39


# Run Gradle Task
./gradlew build
./gradlew owlLoad
