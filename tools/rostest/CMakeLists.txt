cmake_minimum_required(VERSION 3.0.2)
project(rostest)

find_package(catkin COMPONENTS rosunit)
find_package(Boost COMPONENTS thread)

include_directories(include ${Boost_INCLUDE_DIRS})

catkin_package(DEPENDS Boost
  INCLUDE_DIRS include
  CFG_EXTRAS ${PROJECT_NAME}-extras.cmake
  )
catkin_python_setup()

catkin_install_python(
  PROGRAMS nodes/advertisetest nodes/hztest nodes/paramtest nodes/publishtest nodes/subscribetest
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/nodes)
install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
  FILES_MATCHING PATTERN "*.h")

if(CATKIN_ENABLE_TESTING)
  find_package(catkin COMPONENTS rostest)

  catkin_add_gtest(test_permuter test/test_permuter.cpp)
  if(TARGET test_permuter)
    target_link_libraries(test_permuter ${Boost_LIBRARIES})
  endif()

  add_rostest(test/hztest0.test)
  add_rostest(test/hztest.test)
  add_rostest(test/publishtest.test)
  add_rostest(test/clean_master.test)
  add_rostest(test/distro_version.test)
  add_rostest(test/param.test)
  add_rostest(test/advertisetest.test)
  add_rostest(test/subscribetest.test)
endif()
