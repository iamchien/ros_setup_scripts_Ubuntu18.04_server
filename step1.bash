#!/bin/bash -exv

UBUNTU_VER=$(lsb_release -sc)
ROS_VER=melodic
[ "$UBUNTU_VER" = "bionic" ] || exit 1

echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_VER main" > /tmp/$$-deb
sudo mv /tmp/$$-deb /etc/apt/sources.list.d/ros-latest.list

while ! sudo apt-get install -y curl ; do
    echo '***WAITING TO GET A LOCK FOR APT...***'
    sleep 1
done
set -vx

sudo apt install -y curl
curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
sudo apt update || echo ""

sudo apt install -y ros-${ROS_VER}-ros-base

ls /etc/ros/rosdep/sources.list.d/20-default.list && sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
sudo apt install python-pip
sudo -H pip install rosdep
sudo rosdep init 
sudo rosdep update

sudo apt install -y python-rosinstall
sudo apt install -y build-essential
sudo apt install -y rviz

grep -F "source /opt/ros/$ROS_VER/setup.bash" ~/.bashrc ||
echo "source /opt/ros/$ROS_VER/setup.bash" >> ~/.bashrc

grep -F "ROS_MASTER_URI" ~/.bashrc ||
echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc

grep -F "ROS_HOSTNAME" ~/.bashrc ||
echo "export ROS_HOSTNAME=localhost" >> ~/.bashrc

sudo chown $USER:$USER $HOME/.ros/ -R 

### instruction for user ###
set +xv

echo '***INSTRUCTION*****************'
echo '* do the following command    *'
echo '* $ source ~/.bashrc          *'
echo '* after that, try             *'
echo '* $ LANG=C roscore            *'
echo '*******************************'
