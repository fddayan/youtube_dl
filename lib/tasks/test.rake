require_relative "../youtube_dl"

namespace :youtube_dl do
  desc "Run all youtube_dl tests."
  task :test do
    if ARGV[1]
      require_relative(ARGV[1])
    else
      paths = "#{YoutubeDl::ROOT_PATH}/spec/**/*_spec.rb"
      Dir.glob(paths).each { |file| require file }
    end
  end
end
