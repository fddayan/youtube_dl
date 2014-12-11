# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # trusty is required for ffmpeg 1.0 which is required for muxing.
  config.vm.box = 'trusty64'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.synced_folder '.', '/home/vagrant/youtubedl'
  config.vm.provision :shell, {
    privileged: false,
    inline: 'cd /home/vagrant/youtubedl; ./bin/provisioning/setup.sh'
  }

end
