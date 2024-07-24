#!/usr/bin/env bash

# Remove any previous results
rm -rf results/out

# Run snakemake in the background
trap "kill 0" EXIT  # Kill all child processes on exit
snakemake --use-conda --cores 1 --configfile=config/.test.yaml _test & PID=$!

# Create 'ready' trigger in a loop until plots are generated.
# Snakemake can take a while to build the environment and start-up, so we repeatedly
# generate the 'end' trigger (which is removed by the rule during internal startup).
mkdir -p results/end
while kill -0 $PID 2> /dev/null; do
    touch results/end/trigger
    sleep 5  
done
