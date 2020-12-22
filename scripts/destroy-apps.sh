#!/bin/bash

###############
# Delete network policies
###############
cf remove-network-policy $(expand_var $APP_NAME_BAT_BUYER_UI) $(expand_var $APP_NAME_SPREE_UI) -s $SPACE -o $ORG --protocol tcp --port 3000 || true

##################
# BaT Client UI
##################
cf delete -f $(expand_var $APP_NAME_BAT_BUYER_UI)

#######################
# Spree and Sidekiq
#######################
cf delete -f $(expand_var $APP_NAME_SPREE_SIDEKIQ)
cf delete -f $(expand_var $APP_NAME_SPREE_UI)
