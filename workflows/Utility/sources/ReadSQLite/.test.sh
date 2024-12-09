#!/usr/bin/env bash

# Remove any old results
rm -rf results/out

# Run the pipeline, specifying a test configuration file and target rule `_test`
snakemake --cores 1 --configfile=config/.test.yaml _test
