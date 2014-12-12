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

  def youtube(url)
    YoutubeDl::YoutubeVideo.new(url, {
      debug: true
    })
  end

  def assert_valid_download(file_path)
    fail_msg = "File doesn't exist or file size too small."
    assert(File.size?(file_path) > 1000 * 1000, fail_msg)
  end

  # Print the available file formats for a youtube URL.
  def get_available_formats(url)
    yt = youtube(url)
    system(yt.youtube_dl_binary, "--list-formats", url)
  end

  describe "#download_best" do
    describe "when using a single video link" do
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
        expected_file_path = "tmp/downloads/#{youtube_id}.mp4"

        describe "when the url is #{video_url}" do
          # Print available video codecs
          # get_available_formats(video_url)
          it "muxes the video and audio together into one file" do
            begin
              # The library prints to the console.
              result = youtube(video_url).download_best
              assert_equal(expected_file_path, result)
              assert_valid_download(result)
            ensure
              # Delete the file after.
              File.unlink(File.new(expected_file_path)) if result
            end
          end
        end
      end
    end

    describe "when using a playlist link" do
      youtube_ids = [
        # %w(q-ht79j2i9M PL49WgzlbhrT10IN3W4soxNNd46qF6vIvZ)
        %w(gUKxeVSOOBE PLDyKn8uKYtRa-G4gI6gwuyZkw1-B1cw1y)
      ]

      youtube_ids.each do |(video_id, playlist_id)|
        video_url = "https://www.youtube.com/watch?v=#{video_id}&list=#{playlist_id}"
        expected_file_path = "tmp/downloads/#{video_id}.mp4"

        describe "when video=#{video_id} and playlist=#{playlist_id}" do
          it "only downloads the video and not the whole playlist" do
            begin
              # The library prints to the console.
              result = youtube(video_url).download_best
              assert_equal(expected_file_path, result)
              assert_valid_download(result)
              assert_equal(1, Dir["tmp/downloads/*"].size, "More than 1 file was downloaded.")
            ensure
              # Delete the file after.
              File.unlink(File.new(expected_file_path)) if result
            end
          end
        end
      end
    end
  end
end
