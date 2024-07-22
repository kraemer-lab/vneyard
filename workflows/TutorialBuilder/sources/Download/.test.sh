#!/usr/bin/env bash

rm -rf results/out

# !!! AUTO.remote is demonstrating strange behaviour on the github runner; needs investigating

# snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
