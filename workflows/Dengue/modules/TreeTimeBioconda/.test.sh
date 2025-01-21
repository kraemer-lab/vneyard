#!/usr/bin/env bash

if [ ! -d "results" ]; then
    mkdir results
fi
if [ ! -d "results/fasta" ]; then
    ln -s ../../TreeBuilding/results/out results/fasta
    if [ ! -d "results/fasta" ]; then
        echo "No input data found. Please run the TreeBuilding pipeline first."
        exit 1
    fi
fi
if [ ! -d "results/metadata" ]; then
    ln -s ../../Reformatting/results/out results/metadata
    if [ ! -d "results/metadata" ]; then
        echo "No input data found. Please run the Reformatting pipeline first."
        exit 1
    fi
fi
rm -rf results/out
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
