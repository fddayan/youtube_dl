require 'rubygems'
require 'httparty'
require 'uri'
require 'cgi'

module YoutubeDl
  class YoutubeVideo
    YOUTUBE_DL = File.join(File.expand_path(File.dirname(__FILE__)), "../bin/youtube-dl")

    FORMATS = {
      38  => { ext: "mp4"  }, # [3072x4096]
      37  => { ext: "mp4"  }, # [1080x1920]
      46  => { ext: "webm" }, # [1080x1920]
      22  => { ext: "mp4"  }, # [720x1280]
      45  => { ext: "webm" }, # [720x1280]
      35  => { ext: "flv"  }, # [480x854]
      44  => { ext: "webm" }, # [480x854]
      18  => { ext: "mp4"  }, # [360x640]
      43  => { ext: "webm" }, # [360x640]
      34  => { ext: "flv"  }, # [360x640]
      137 => { ext: "mp4",  only: "video" }, # [1920x1080]
      248 => { ext: "webm", only: "video" }, # [1920x1080]
      136 => { ext: "mp4",  only: "video" }, # [1280x720]
      247 => { ext: "webm", only: "video" }, # [1280x720]
      135 => { ext: "mp4",  only: "video" }, # [854x480]
      244 => { ext: "webm", only: "video" }, # [854x480]
      134 => { ext: "mp4",  only: "video" }, # [640x360]
      243 => { ext: "webm", only: "video" }, # [640x360]
      133 => { ext: "mp4",  only: "video" }, # [426x240]
      242 => { ext: "webm", only: "video" }, # [426x240]
      160 => { ext: "mp4",  only: "video" }, # [256x144]
      278 => { ext: "webm", only: "video" }, # [256x144]
      141 => { ext: "m4a",  only: "audio" }, # 256k (44100Hz)
      172 => { ext: "webm", only: "audio" }, # 256k (44100Hz)
      140 => { ext: "m4a",  only: "audio" }, # 128k (44100Hz)
      171 => { ext: "webm", only: "audio" }, # 128k (44100Hz)
      139 => { ext: "m4a",  only: "audio" }  #  48k (22050Hz)
    }

    def self.add_formats(formats)
      FORMATS.merge!(formats)
    end

    def self.get_format_argument(video_code, audio_code = nil)
      if audio_code.nil?
        video_code.to_s
      else
        "#{video_code}+#{audio_code}"
      end
    end

    def initialize(page_uri, options = {})
      @uri = URI.parse page_uri
      @location = options[:location] || "tmp/downloads" # default path
      @format = options[:format] || 18                  # default format
      @audio_format = options[:audio_format]            # default audio_format
      @youtube_dl_binary = options[:youtube_dl_binary] || YOUTUBE_DL
      @debug = options[:debug]
    end

    def youtube_dl_binary
      @youtube_dl_binary
    end

    def video_id
      params(@uri.query)['v'].first
    end

    def title
      extended_info_body['title'].first if extended_info.code == 200
    end

    def get_url
      system(youtube_dl_binary, '-g', @uri.to_s)
    end

    def extended_info
      @video_info ||= HTTParty.get("http://www.youtube.com/get_video_info?video_id=#{video_id}&el=detailpage")
    end

    # Download the best quality available and mux with ffmpeg if needed.
    def download_best
      download_video({
        :format => "bestvideo",
        :audio_format => "bestaudio"
      })
    end

    def download_video(options = {})
      video_format_code = (options[:format] || @format)
      audio_format_code = (options[:audio_format] || @audio_format)
      format_argument = self.class.get_format_argument(video_format_code, audio_format_code)

      filename = video_filename

      args = [youtube_dl_binary]
      if !@debug
        args.push '-q', '--no-progress'
      end
      args.push '-o', filename, '-f', format_argument, '--restrict-filenames', @uri.to_s

      quiet = @debug ? '' : '-q'
      system(*args)
      # TODO: Fix video_filename for non-mp4 files.
      filename if File.exist?(filename)
    end

    def download_preview(options = {})
      link = if !extended_info_body["iurlsd"].blank?
        extended_info_body["iurlsd"].first
      else
        extended_info_body["thumbnail_url"].first
      end
      system('wget', '-O', preview_filename, link)

      preview_filename if File.exist?(preview_filename)
    end

    def preview_filename
      File.join(@location, "#{video_id}.jpg")
    end

    # TODO: don't always name .mp4
    def video_filename
      File.join(@location, "#{video_id}.mp4")
    end

    def extended_info_body
      params(extended_info.body)
    end

    private

    def params(body)
      CGI.parse(body)
    end

  end
end
