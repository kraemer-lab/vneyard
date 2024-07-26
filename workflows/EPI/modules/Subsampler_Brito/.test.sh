#!/usr/bin/env bash

# Test as workflow
rm -rf results/out
snakemake \
    --cores 1 \
    --use-conda \
    --configfile=config/.test.yaml \
    _test

# Test as module
rm -rf results/out
snakemake \
    --cores 1 \
    --use-conda \
    --snakefile workflow/.Snakefile.test.module \
    --configfile=config/.test.module.yaml \
    subsampler_brito__test
