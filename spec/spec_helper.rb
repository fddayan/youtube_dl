require_relative "../lib/youtube_dl"
require "fileutils"
require "minitest/spec"
require "minitest/autorun"

# Remove any leftover downloads from previous erroneous runs.
FileUtils.rm(Dir[File.join('.', 'tmp', 'downloads', '*')])
