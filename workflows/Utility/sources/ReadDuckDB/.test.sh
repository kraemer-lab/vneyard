#!/usr/bin/env bash

# Remove any old results
rm -rf results/out

# Run the pipeline, specifying a test configuration file and target rule `_test`
snakemake --cores 1 --use-conda --configfile=config/.test.yaml _test
