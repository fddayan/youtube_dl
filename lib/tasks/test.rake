require_relative "../youtube_dl"

namespace :test do
  desc "Run all tests."
  task :run do
    if ARGV[1]
      require_relative(ARGV[1])
    else
      Dir.glob("#{YoutubeDl::ROOT_PATH}/spec/**/*_spec.rb").each { |file| require file }
    end
  end
end

task :test => "test:run"
