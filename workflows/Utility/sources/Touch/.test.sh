#!/usr/bin/env bash

rm -rf results
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test
