#!/usr/bin/env rake

require "bundler"
Bundler::GemHelper.install_tasks

require_relative "lib/youtube_dl"

Dir["#{YoutubeDl::ROOT_PATH}/lib/tasks/*.rake"].each { |file| load(file) }
