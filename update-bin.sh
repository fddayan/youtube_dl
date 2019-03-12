set -e # exit when any command fails

CURL_URL="https://yt-dl.org/downloads/latest/youtube-dl"
OUTPUT_PATH="bin/youtube-dl"

echo "Running curl with sudo..."
sudo curl -L "$CURL_URL" -o "$OUTPUT_PATH"
