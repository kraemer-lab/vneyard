#!/usr/bin/env bash

rm -rf results/out

# We use dry-run to test the pipeline without running it (as the module requires user interaction)
snakemake --use-conda --cores 1 --dry-run --configfile=config/.test.yaml _test
