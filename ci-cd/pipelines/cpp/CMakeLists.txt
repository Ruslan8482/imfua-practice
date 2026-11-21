cmake_minimum_required(VERSION 3.16)
project(hello_cpp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(sum_lib src/sum.cpp)
target_include_directories(sum_lib PUBLIC src)

add_executable(hello-cpp src/main.cpp)
target_link_libraries(hello-cpp PRIVATE sum_lib)

enable_testing()
add_executable(test_sum tests/test.cpp)
target_link_libraries(test_sum PRIVATE sum_lib)
add_test(NAME test_sum COMMAND test_sum)
