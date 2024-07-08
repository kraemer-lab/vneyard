#!/usr/bin/env bash

rm -rf results/out
CONDA_SUBDIR=osx-64 snakemake --cores 1 --use-conda --configfile=config/.test.yaml _test
