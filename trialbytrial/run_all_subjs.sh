#!/bin/bash

models=$1 # keep empty to run all models
ninits=$2

models_short='zz Bayesian logBayesian additive mostP_voter mostleast2_voter most2_voter least2_voter feedbackRL_1alpha logfeedbackRL_1alpha zz'
models_long='zz mostleast_voter feedbackRL logfeedbackRL zz'
models_longlong=''
if [ -z "$models" ]; then
    models="$models_short $models_long $models_longlong"
fi

subjnums='101 102 103 104 105 106 107 108 109 110 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 129 130 131 132 133 134'
use_likelihood_estimates='0 1'
if [ -z "$ninits" ]; then
    ninits=10
fi

for model in $models; do
    for subjnum in $subjnums; do
	for ule in $use_likelihood_estimates; do
	    if [ ! -z "`echo $models_short | grep \" $model \"`" ]; then
		submit_short run_model.m $model $subjnum $ule $ninits
	    elif [ ! -z "`echo $models_long | grep \" $model \"`" ]; then
                for init in `seq 1 $ninits`; do
		    submit_short run_model.m $model $subjnum $ule $ninits $init
                done
	    elif [ ! -z "`echo $models_longlong | grep \" $model \"`" ]; then
                for init in `seq 1 $ninits`; do
		    submit_long run_model.m $model $subjnum $ule $ninits $init
                done
	    else
		echo "ERROR: $model is an invalid model"
	    fi
	done
    done
done