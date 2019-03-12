# youtube_dl gem

This is a youtube_dl video downloader wrapper.

## Usage
    >> youtube = YoutubeDl::YoutubeVideo.new("http://www.youtube.com/watch?v=zzG4K2m_j5U")
    >> video = youtube.download_video
    => "tmp/downloads/zzG4K2m_j5U.mp4"
    >> preview = youtube.download_preview
    => "tmp/downloads/zzG4K2m_j5U.jpg"

## Updating Binary
    Running `sh update-bin.sh` will update `bin/youtube_dl` automattically. If there is an error you will need to go to the [download page](https://rg3.github.io/youtube-dl/download.html) and update manually.

## Changelog

### 0.0.2
Update youtube_dl script to last binary version. This update fixed download from youtube error.

### 0.0.1
Initial release.
