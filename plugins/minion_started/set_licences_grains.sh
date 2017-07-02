#!/bin/bash

read minion

#TODO API CALL FOR LICENCES

salt "$minion" grains.set GRAINNAME "GRAIN-VALUE“ 
