#!/bin/sh

FLEX_HOME=/Applications/Adobe\ Flex\ Builder\ 3/sdks/3.2.0/;
PROJ_PATH=/Users/tom/Documents/Stamen/ModestMapsV1/modestmaps/trunk/as3;

cd "$FLEX_HOME";            
pwd
bin/asdoc -doc-sources $PROJ_PATH/lib -output $PROJ_PATH/docs
