require_relative "../spec_helper"

describe YoutubeDl::YoutubeVideo do
  describe "#get_format_argument" do
    [
      [22, 45, "22+45"],
      [22, nil, "22"]
    ].each do |video, audio, expected|
      describe "when video=#{video} and audio=#{audio}" do
        it "returns #{expected.inspect}" do
          result = YoutubeDl::YoutubeVideo.get_format_argument(video, audio)
          assert_equal(expected, result)
        end
      end
    end
  end

  describe "#download_best" do
    def youtube(url)
      YoutubeDl::YoutubeVideo.new(url, {
        debug: true
      })
    end

    # Print the available file formats for a youtube URL.
    def get_available_formats(url)
      yt = youtube(url)
      system(yt.youtube_dl_binary, "--list-formats", url)
    end

    youtube_ids = [
      # 1080p
      "y4QQbdQ0DT8",
      # "s3Qm6PjU_cs",
      # "VZeDkRcBW9Y",

      # 720p
      "moCbcan7cSM",

      # 480p
      "MAsrDu3pL2g",

      # 360p
      # TODO: let 360p downloads work with "bestvideo", "bestaudio"
      # "kfchvCyHmsc",
      # "cTZC-j48JWg",
      # "9AfHAfhrWBg",
    ]

    youtube_ids.each do |youtube_id|
      video_url = "https://www.youtube.com/watch?v=#{youtube_id}"

      describe "when the url is #{video_url}" do
        # Print available video codecs
        # get_available_formats(video_url)

        it "muxes the video and audio together into one file" do
          expected_file_path = "tmp/downloads/#{youtube_id}.mp4"

          begin
            # The library prints to the console..
            result = youtube(video_url).download_best
            puts "result", result
            assert_equal(expected_file_path, result)
          ensure
            # Delete the file after.
            File.unlink(File.new(expected_file_path)) if result
          end
        end
      end
    end
  end
end
