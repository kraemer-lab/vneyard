#!/usr/bin/env bash

if [ ! -d "results" ]; then
    mkdir results
fi
if [ ! -d "results/fasta" ]; then
    ln -s ../../HyphyCln/results/out results/fasta
fi
if [ ! -d "results/fasta" ]; then
    echo "No input data found. Please run the HyphyCln pipeline first."
    exit 1
fi
if [ ! -d "results/tree" ]; then
    ln -s ../../TreeBuildingNoStopCodons/results/out results/tree
fi
if [ ! -d "results/tree" ]; then
    echo "No input data found. Please run the TreeBuildingNoStopCodons pipeline first."
    exit 1
fi
rm -rf results/out
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
