require_relative "../youtube_dl"

namespace :test do
  desc "Run all youtube_dl tests."
  task :youtube_dl do
    if ARGV[1]
      require_relative(ARGV[1])
    else
      paths = "#{YoutubeDl::ROOT_PATH}/spec/**/*_spec.rb"
      Dir.glob(paths).each { |file| require file }
    end
  end
end

desc "Run all youtube_dl tests."
task :test => "test:youtube_dl"
