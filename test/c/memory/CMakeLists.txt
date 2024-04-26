cmake_minimum_required(VERSION 3.29)
project(memory VERSION 1.0.1 DESCRIPTION "for ffi memory test")
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(memory SHARED
    src/memory.cpp
)

set_target_properties(memory PROPERTIES VERSION ${PROJECT_VERSION})
set_target_properties(memory PROPERTIES SOVERSION ${PROJECT_VERSION_MAJOR})

set_target_properties(memory PROPERTIES PUBLIC_HEADER include/memory.h)

target_compile_definitions(memory PUBLIC SHARED_LIB)