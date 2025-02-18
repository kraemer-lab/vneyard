#!/usr/bin/env bash

if [ ! -d "results" ]; then
    mkdir results
fi
if [ ! -d "results/original" ]; then
    ln -s ../../TreeTimeBioconda/results/out results/original
fi
if [ ! -d "results/original" ]; then
    echo "No input data found. Please run the TreeTimeBioconda pipeline first."
    exit 1
fi
if [ ! -d "results/cleaned" ]; then
    ln -s ../../RemoveAnnotations/results/out results/cleaned
fi
if [ ! -d "results/cleaned" ]; then
    echo "No input data found. Please run the RemoveAnnotations pipeline first."
    exit 1
fi
rm -rf results/out
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
