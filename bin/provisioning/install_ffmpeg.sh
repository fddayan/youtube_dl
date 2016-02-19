## Install real ffmpeg
sudo apt-get update
sudo apt-get -y install python-software-properties
# http://www.noobslab.com/2014/12/ffmpeg-returns-to-ubuntu-1410.html
sudo add-apt-repository -y ppa:kirillshkrogalev/ffmpeg-next
# This PPA is removed and now you cannot install ffmpeg with this PPA.
# sudo add-apt-repository -y ppa:jon-severinsson/ffmpeg
sudo apt-get update
sudo apt-get -y install ffmpeg
sudo apt-get -y install frei0r-plugins
## -----------------------------------------------------------
