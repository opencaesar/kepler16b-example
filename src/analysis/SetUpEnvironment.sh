#!/bin/bash

# Run this command on the terminal or command line by running (assuming running from the root of the repo):
# 1. chmod +x src/analysis/SetUpEnvironment.sh 
# 2. ./src/analysis/SetUpEnvironment.sh

# Install R packages
R -e "install.packages('reactable', repos='http://cran.us.r-project.org')"
R -e "install.packages('igraph')"
R -e "install.packages('networkD3')"
R -e "install.packages('reticulate')"
R -e "install.packages('tidyverse')"
R -e "install.packages('collapsibleTree')"
R -e "install.packages('colorspace')"
R -e "install.packages('jsonlite')"
R -e "install.packages('DT')"
R -e "install.packages('devtools')"
R -e "library(devtools); install_github('UTNAK/tansakusuR')"
R -e "library(devtools); install_github('UTNAK/omlhashiR')"

# Create and update conda environment
conda env create --file environment.yml
conda env update --file environment.yml --prune
conda init

# Install libglpk40 package
sudo apt-get update
sudo apt-get install -y libglpk40

# Fix libstdc++.so.6 for Quarto + Reticulate
cd /opt/conda/envs/py39/lib/
sudo cp libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so.6