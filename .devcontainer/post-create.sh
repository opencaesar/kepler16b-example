#!/bin/sh

conda env create --file environment.yml

conda init

# these two commands dont work well
#conda activate py39

# Install R packages
# Rscript ./.devcontainer/install_rpackage.R 

# Install R packages
R -e "install.packages('reactable')"
R -e "install.packages('igraph')"
R -e "install.packages('networkD3')"
R -e "install.packages('reticulate')"
R -e "install.packages('tidyverse')"
R -e "install.packages('collapsibleTree')"
R -e "install.packages('colorspace')"
R -e "install.packages('jsonlite')"
R -e "install.packages('DT')"
R -e "install.packages('pak')"
R -e "pak::pkg_install('UTNAK/tansakusuR')"
R -e "pak::pkg_install('UTNAK/omlhashiR')"


## Install libglpk40 package in the terminal for igraph
sudo apt-get update
sudo apt install -y libglpk40


## Fix libstdc++.so.6 for Quarto + Reticulate
cd /opt/conda/envs/py39/lib/
sudo cp libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so.6


# Run Gradle Task
./gradlew build
./gradlew owlLoad
