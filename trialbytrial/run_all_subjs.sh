#!/bin/bash

models_short='Bayesian logBayesian additive'
models_long='mostleast_voter feedbackRL logfeedbackRL'
subjnums='101 102 103 104 105 106 107 108 109 110 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 129 130 131 132 133 134'
use_likelihood_estimates='0 1'
ninits=10

for subjnum in $subjnums; do
    for ule in $use_likelihood_estimates; do
	for model in $models_short; do
	    submit_short run_model.m $model $subjnum $ule $ninits
	done
	for model in $models_long; do
	    submit_long run_model.m $model $subjnum $ule $ninits
	done
    done
done