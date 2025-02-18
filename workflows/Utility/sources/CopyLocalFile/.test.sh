#!/usr/bin/env bash

if [ ! -d "results" ]; then
    mkdir -p results
fi
if [ ! -d "results/in" ]; then
    mkdir -p results/in
    touch results/in/test.file
fi
rm -rf results/out
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
