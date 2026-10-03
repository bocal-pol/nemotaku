cmake_minimum_required(VERSION 3.21)
project(Nemotaku LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(src/core)
add_subdirectory(src/cef-client)
add_subdirectory(src/ui)
