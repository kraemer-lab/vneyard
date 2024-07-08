#!/usr/bin/env bash

set -eoux pipefail

if [ -z "${CONDA_PREFIX}" ]; then
    echo "CONDA_PREFIX is not set"
    exit 1
fi

if [ -z "${R_LIBS_USER:-}" ]; then
    export R_LIBS_USER=${CONDA_PREFIX}/lib/R/lib
fi

if [ $(Rscript -e "cat('EpiLine' %in% rownames(installed.packages()))") == "FALSE" ]; then
    echo "Installing EpiLine"
    mkdir -p resources
    rm -rf resources/EpiLine
    git clone \
        https://github.com/BDI-pathogens/EpiLine.git \
        -b main \
        resources/EpiLine
    pushd resources/EpiLine
    git checkout f4ba1872e2fe25e9d4ed4c6dd6c525ddfc26d493

    # Patch Makevars to include RcppParallel headers
    RCPP_PACKAGE_PATH=$(Rscript -e "cat(find.package('RcppParallel'))")
    PKG_CPPFLAGS=$(sed -n 's/^PKG_CPPFLAGS = //p' src/Makevars)
    PKG_CPPFLAGS="-D_REENTRANT -I"${RCPP_PACKAGE_PATH}/include" ${PKG_CPPFLAGS}"
    sed -i "s@^PKG_CPPFLAGS = @&${PKG_CPPFLAGS} @" src/Makevars

    # Reinstall RcppParallel
    Rscript -e "install.packages('RcppParallel', repos='https://cloud.r-project.org/')"

    # Install package
    Rscript -e "install.packages('.', repos=NULL, type='source')"
    popd

    # Verify package installation
    if [ $(Rscript -e "cat('EpiLine' %in% rownames(installed.packages()))") == "FALSE" ]; then
        echo "EpiLine installation failed"
        exit 1
    fi
else
    echo "EpiLine already installed"
fi
