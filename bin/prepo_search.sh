#!/bin/bash

# recursively searches through the prepo paper text for a string

grep -Hrnw $PREPO_ROOT/papers/*/*.tex $PREPO_ROOT/papers/*/meta -e "$1"
