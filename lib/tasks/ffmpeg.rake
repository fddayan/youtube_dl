require_relative "../youtube_dl"

namespace :youtube_dl do
  namespace :ffmpeg do
    desc "Install ffmpeg."
    task :install do
      puts "Installing ffmpeg..."
      path = "#{YoutubeDl::ROOT_PATH}/bin/provisioning/install_ffmpeg.sh"
      system(path)
    end
  end
end
