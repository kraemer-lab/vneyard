#!/usr/bin/env bash

if [ ! -d "results" ]; then
    mkdir results
fi
if [ ! -d "results/tree" ]; then
    ln -s ../../HyphyRemoveDupes/results/out results/tree
fi
if [ ! -d "results/tree" ]; then
    echo "No input data found. Please run the HyphyRemoveDupes pipeline first."
    exit 1
fi
if [ ! -d "results/strains" ]; then
    ln -s ../../FilterAfricaStrains/results/out results/strains
fi
if [ ! -d "results/strains" ]; then
    echo "No input data found. Please run the FilterAfricaStrains pipeline first."
    exit 1
fi
rm -rf results/out workspace
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
