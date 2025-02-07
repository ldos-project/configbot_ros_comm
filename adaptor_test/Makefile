SHELL := /bin/bash

all:
	source ~/ros_catkin_ws/devel_isolated/setup.bash && ccache g++ -std=c++14 -o node.o node.cpp `pkg-config --cflags --libs roscpp std_msgs`
