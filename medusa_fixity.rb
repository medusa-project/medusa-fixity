#!/usr/bin/env ruby
require_relative 'lib/medusa_fixity_server'

#only run if given run as the first argument. This is useful for letting us load this file
#in irb to work with things interactively when we need to
MedusaFixityServer.new(config_file: 'config/medusa_fixity.yaml').run if ARGV[0] == 'run'
