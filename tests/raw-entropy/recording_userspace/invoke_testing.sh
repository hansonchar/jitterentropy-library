#!/bin/bash

# Directory where to store the measurements
OUTDIR="../results-measurements"

# Maximum number of entries to be extracted from the original file
NUM_EVENTS=1000000

# Number of restart tests
NUM_EVENTS_RESTART=1000
NUM_RESTART=1000

NONIID_RESTART_DATA="jent-raw-noise-restart"
NONIID_DATA="jent-raw-noise"

# Define the maximum memory size
# 0 -> use default
# 1 -> JENT_MAX_MEMSIZE_32kB
# ...
# 15 -> JENT_MAX_MEMSIZE_512MB
MAX_MEMORY_SIZE=0

# If this variable is set to any value, the timer-less entropy source
# is forced and tested
FORCE_NOTIME_NOISE_SOURCE=""

initialization()
{
    if [ ! -d $OUTDIR ]
    then
        if ! mkdir $OUTDIR; then
            echo "Creation of $OUTDIR failed"
            exit 1
        fi
    fi

    trap "make -s -f Makefile.rng clean; make -s -f Makefile.hashtime clean; exit" 0 1 2 3 15
}

raw_entropy_restart()
{
    echo "Obtaining $NUM_RESTART raw entropy measurement with $NUM_EVENTS_RESTART restarts from Jitter RNG"

    make -s -f Makefile.hashtime

    # shellcheck disable=SC2086
    ./jitterentropy-hashtime $NUM_EVENTS_RESTART $NUM_RESTART $OUTDIR/$NONIID_RESTART_DATA $MAX_MEMORY_SIZE $FORCE_NOTIME_NOISE_SOURCE

    make -s -f Makefile.hashtime clean
}

raw_entropy()
{
    echo "Obtaining $NUM_EVENTS raw entropy measurement from Jitter RNG"

    make -s -f Makefile.hashtime

    # shellcheck disable=SC2086
    ./jitterentropy-hashtime $NUM_EVENTS 1 $OUTDIR/$NONIID_DATA $MAX_MEMORY_SIZE $FORCE_NOTIME_NOISE_SOURCE

    make -s -f Makefile.hashtime clean
}

initialization
raw_entropy
raw_entropy_restart
