require 'rubygems'
require 'httparty'
require 'uri'
require 'cgi'

module YoutubeDl
  ROOT_PATH = File.expand_path('../../', __FILE__)

  def self.load_rake_tasks
    path = "#{YoutubeDl::ROOT_PATH}/lib/tasks/*.rake"
    Dir[path].each { |file| load(file) }
  end

  class YoutubeVideo
    YOUTUBE_DL = "#{ROOT_PATH}/bin/youtube-dl"

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

    module ClassMethods
      def add_formats(formats)
        FORMATS.merge!(formats)
      end

      def get_format_argument(video_code, audio_code = nil)
        if audio_code.nil?
          video_code.to_s
        else
          "#{video_code}+#{audio_code}"
        end
      end

      # Given a URI, get the YouTube video ID.
      #
      # @param uri [URI]
      #
      # @return video_id [String]
      def get_video_id(uri)
        if uri.to_s =~ /^https?\:\/\/(?:www\.)?youtube\.com\/watch/
          params(uri.query)['v'].first
        elsif uri.to_s =~ /^https?\:\/\/(?:www\.)?youtu\.be\/([\w_-]+)/
          $1
        end
      end

      def params(body)
        CGI.parse(body)
      end
    end
    extend ClassMethods


    attr_reader :video_id


    def initialize(page_uri, options = {})
      @uri = URI.parse(page_uri)
      @video_id = self.class.get_video_id(@uri)
      @location = options[:location] || "tmp/downloads" # default path
      @format = options[:format] || 18                  # default format
      @audio_format = options[:audio_format]            # default audio_format
      @youtube_dl_binary = options[:youtube_dl_binary] || YOUTUBE_DL
      @debug = options[:debug]
    end

    def youtube_dl_binary
      @youtube_dl_binary
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
    def download_best(options = {})
      download_video({
        :format => "bestvideo",
        :audio_format => "bestaudio"
      }.merge(options))
    end

    def download_video(options = {})
      video_format_code = (options[:format] || @format)
      audio_format_code = (options[:audio_format] || @audio_format)
      format_argument = self.class.get_format_argument(video_format_code, audio_format_code)


      args = system_args(tmp_filename, format_argument)
      system(*args)

      filename = video_filename

      filename if File.exist?(filename)
    end

    # Get an array to send as system arguments to the youtube_dl binary.
    #
    # @param filename [String]
    # @param format [String]
    #
    # @return args [Array]
    def system_args(filename, format)
      [youtube_dl_binary].tap do |args|
        if @debug
          args.push '-v'
        else
          args.push '-q', '--no-progress'
        end

        args.push(
          # What to name the file locally.
          '-o', filename,
          # YouTube format code.
          '--merge-output-format', format,
          # Don't use stupid characters for the local filename.
          '--restrict-filenames',
          # Only download the linked video, not every video in the playlist.
          '--no-playlist',
          @uri.to_s
        )
      end
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

    # TODO: don't always name .jpg
    def preview_filename
      File.join(@location, "#{video_id}.jpg")
    end

    # Check existing files for one matching the video id, with any extension.
    # If none found, return video id with mp4 extension.
    #
    # @return [String]
    #
    # @example
    #   igCpDUju7Qw.mp4
    #   3HYn2CFSdsg.mkv
    def video_filename
      Dir[File.join(@location, "#{video_id}.*")].find do |filename|
        File.basename(filename, ".*") == video_id
      end || File.join(@location, "#{video_id}.mp4")
    end

    def tmp_filename
      File.join(@location, video_id)
    end

    def extended_info_body
      self.class.params(extended_info.body)
    end

  end
end
