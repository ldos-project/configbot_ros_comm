cmake_minimum_required(VERSION 3.0.2)
project(rospy)
find_package(catkin REQUIRED COMPONENTS message_generation std_msgs)

# generate adaptor message format
add_service_files(FILES AdaptorService.srv)
catkin_python_setup()
generate_messages(DEPENDENCIES std_msgs)

catkin_package(CATKIN_DEPENDS message_runtime std_msgs)

# install legacy infrastructure needed by rosbuild
install(FILES rosbuild/rospy.cmake
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/rosbuild)
catkin_install_python(PROGRAMS
  rosbuild/scripts/genmsg_py.py
  rosbuild/scripts/gensrv_py.py
  rosbuild/scripts/genutil.py
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/rosbuild/scripts)

