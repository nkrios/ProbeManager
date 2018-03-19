#!/usr/bin/env bash

# Get args
if [ -z $1 ]; then
    arg=""
else
    arg='--app '$@
fi
source=''
sourcecoverage=''
for app in $@
do
    source="$source"" probemanager/""$app"
    sourcecoverage="$sourcecoverage""probemanager/""$app"","
done
sourcecoverage="--source=""$sourcecoverage"

if [[ "$TRAVIS" = true ]]; then
    flake8 $source --config=.flake8
    coverage erase
    coverage run $sourcecoverage probemanager/runtests.py $arg
    coverage report -i --skip-covered
    if [ -f .coveralls.yml ]; then
        coveralls
    fi
    if [ -f probemanager/probemanager-error.log ]; then
        echo "#### LOGS ####"
        echo "## ERROR ##"
        cat probemanager/probemanager-error.log
        echo "## ALL ##"
        cat probemanager/probemanager.log
    fi
else
    if [ ! -d venv ]; then
        echo 'Install before testing'
        exit
    fi
    if [[ "$VIRTUAL_ENV" = "" ]]; then
        source venv/bin/activate
    fi
    venv/bin/flake8 $source --config=.flake8
    venv/bin/coverage erase
    venv/bin/coverage run $sourcecoverage probemanager/runtests.py $arg
    venv/bin/coverage report -i --skip-covered
    venv/bin/coverage html
    if [ -f .coveralls.yml ]; then
        venv/bin/coveralls
    fi
fi


