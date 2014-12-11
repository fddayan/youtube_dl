#!/usr/bin/env rake

require 'bundler'

Bundler::GemHelper.install_tasks

namespace :test do
  task :run do
    Dir.glob("./lib/**/*.rb").each { |file| require file }

    if ARGV[1]
      require_relative(ARGV[1])
    else
      Dir.glob("./spec/**/*_spec.rb").each { |file| require file }
    end
  end
end

task :test => "test:run"
