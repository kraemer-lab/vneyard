#!/usr/bin/env bash

if [ ! -d "results" ]; then
    mkdir results
fi
if [ ! -d "results/csv" ]; then
    ln -s ../../Reformatting/results/out results/csv
fi
if [ ! -d "results/csv" ]; then
    echo "No input data found. Please run the Reformatting pipeline first."
    exit 1
fi
if [ ! -d "results/fasta" ]; then
    ln -s ../../HyphyCln/results/out results/fasta
fi
if [ ! -d "results/fasta" ]; then
    echo "No input data found. Please run the HyphyCln pipeline first."
    exit 1
fi
rm -rf results/out
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
