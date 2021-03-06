#!/bin/bash

models=$1 # keep empty to run all models
ninits=$2
subjnums=$3
use_likelihood_estimates=$4

models_short='zz Bayesian logBayesian additive Bayesian_recencyprimacy Bayesian_recencyprimacy_sameweight Bayesian_recency Bayesian_primacy mostP_voter mostleast2_voter most2_voter least2_voter feedbackRL_1alpha feedbackRL_correctalso_1alpha zz'
models_long=''
if [ -z "$models" ]; then
    models="$models_short $models_long $models_longlong"
fi

if [ -z "$ninits" ]; then
    ninits=10
fi

if [ -z "$subjnums" ]; then
    subjnums='101 102 103 104 105 106 107 108 109 110 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 129 130 131 132 133 134'
fi

if [ -z "$use_likelihood_estimates" ]; then
    if [ ! -z "`echo $model | grep 'backwards_feedbackRL'`" ]
        then use_likelihood_estimates=1
    else
        use_likelihood_estimates='0 1'
    fi
fi


for model in $models; do
    for subjnum in $subjnums; do
	for ule in $use_likelihood_estimates; do
	    if [ ! -z "`echo $models_short | grep \" $model \"`" ]; then
		submit_short run_model.m $model $subjnum $ule $ninits
	    elif [ ! -z "`echo $models_long | grep \" $model \"`" ]; then
                submit_long $ninits run_model.m $model $subjnum $ule $ninits taskID
            else
                submit_short $ninits run_model.m $model $subjnum $ule $ninits taskID
	    fi
	done
    done
done