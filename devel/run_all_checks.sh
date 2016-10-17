#! /bin/bash

# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

# Runs the project's unit tests and some end-to-end acceptance tests 
# that compare complete syntax files (i.e., expected vs. actual).

DIR=`dirname $0`
RMARGS="${DIR}/output_result/*.*"
SYARGS="${DIR}/front_end.rb ${DIR}/input/all_vars.yaml ${DIR}/input/controller.yaml"

echo; echo "Running unit tests..."
ruby -w tests/ts_all.rb

mkdir -p "${DIR}/output_result/"

rm -f ${RMARGS}

echo; echo "Running end-to-end acceptance comparisons..."
ruby -w ${SYARGS}                # Regular run.
ruby -w ${SYARGS} ALL            # Run for all data structures (hier and rect).
ruby -w ${DIR}/api_example.rb    # A run using the API.
sh ${DIR}/check_output.sh cmp    # Compare the output.

