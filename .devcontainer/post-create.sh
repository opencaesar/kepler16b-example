#!/bin/sh

conda env create --file environment.yml

# these two commands dont work well
#conda init
#conda activate py39

# Install R packages
# Rscript ./.devcontainer/install_rpackage.R 

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
R -e "install.packages('pak')"
R -e "pak::pkg_install('UTNAK/tansakusuR')"
R -e "pak::pkg_install('UTNAK/omlhashiR')"


# Run Gradle Task
./gradlew build
./gradlew owlLoad
