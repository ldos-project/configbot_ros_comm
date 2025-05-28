FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Chicago

RUN apt-get update
RUN apt-get install -y tmux nano lsb-release curl gnupg build-essential python3-pip apt-utils
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt-get update || true
# RUN apt-get install -y python3-rosdep2 python3-rosinstall-generator python3-vcstools
RUN pip3 install rosdep rosinstall_generator vcstool catkin_pkg catkin_tools rospkg
RUN rosdep init || echo "rosdep already initialized" && rosdep update

RUN mkdir -p ~/ros_catkin_ws/src && cd ~/ros_catkin_ws && rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall 
RUN cd ~/ros_catkin_ws && vcs import --input noetic-desktop.rosinstall ./src
RUN cd ~/ros_catkin_ws && rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y --skip-keys="hddtemp python3-catkin-pkg-modules python3-rospkg-modules python3-rosdep-modules" || true
RUN cd ~/ros_catkin_ws && rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y --skip-keys="hddtemp python3-catkin-pkg-modules python3-rospkg-modules python3-rosdep-modules"

# clone ros_comm
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
RUN mkdir -p /root/.ssh
RUN apt-get install -y git wget ccache tree

RUN cd ~/ && git clone https://github.com/ldos-project/configbot_ros_comm
RUN rm -rfv /root/ros_catkin_ws/src/ros_comm/roscpp /root/ros_catkin_ws/src/ros_comm/rospy
RUN ln -s /root/configbot_ros_comm/clients/rospy/ /root/ros_catkin_ws/src/ros_comm && ln -s /root/configbot_ros_comm/clients/roscpp/ /root/ros_catkin_ws/src/ros_comm

# remove and reinstall log4cxx
RUN wget https://archive.apache.org/dist/logging/log4cxx/0.10.0/apache-log4cxx-0.10.0.tar.gz && tar -xzf apache-log4cxx-0.10.0.tar.gz && \
    cd apache-log4cxx-0.10.0 && \
    sed -i '/define _LOG4CXX_STRING_H/i#include <cstring>' src/main/include/log4cxx/logstring.h && \
    ./configure CXXFLAGS="-Wno-narrowing -fpermissive" && \
    make -j && make install && \
    ln -sf /usr/local/lib/liblog4cxx.so /usr/lib/x86_64-linux-gnu/liblog4cxx.so && \ 
    ln -sf /usr/local/lib/liblog4cxx.so.10 /usr/lib/x86_64-linux-gnu/liblog4cxx.so.10 && \
    ln -sf /usr/local/lib/liblog4cxx.so.10.0.0 /usr/lib/x86_64-linux-gnu/liblog4cxx.so.10.0.0 && \
    ldconfig

# build modified ROS
RUN cd ~/ros_catkin_ws && ./src/catkin/bin/catkin_make_isolated --install
RUN pip3 install torch torchvision
RUN pip3 install bayesian-optimization numpy==1.24.0
RUN echo "source ~/ros_catkin_ws/devel_isolated/setup.bash" >> ~/.bashrc