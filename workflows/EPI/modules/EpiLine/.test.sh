#!/usr/bin/env bash

rm -rf results/out
CONDA_SUBDIR=osx-64 snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
