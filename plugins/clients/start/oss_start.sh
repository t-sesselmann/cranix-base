#!/bin/bash
# Copyright (c) 2012-2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

CLIENT=$1

#Apply high state
salt $1 state.apply &> /dev/null

