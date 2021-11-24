cmake_minimum_required(VERSION 3.19)
project(litespeed)

set(CMAKE_CXX_STANDARD 17)

if (NOT DEFINED SQLITE3_INCLUDE_DIR)
    message(FATAL_ERROR "Missing required argument: SQLITE3_INCLUDE_DIR")
endif ()

if (NOT DEFINED SQLITE3_LIB_DIR)
    message(FATAL_ERROR "Missing required argument: SQLITE3_LIB_DIR")
endif ()

find_library(SQLite3 sqlite3 PATHS ${SQLITE3_LIB_DIR} NO_DEFAULT_PATH)
if (SQLite3)
    message(STATUS "Found SQLite3: ${SQLite3}")
else()
    message(FATAL_ERROR "Could not find SQLite3 (searched in ${SQLITE3_LIB_DIR})")
endif()

add_library(bloom SHARED bloom.c)
target_link_libraries(bloom ${SQLite3})
target_include_directories(bloom PRIVATE ${SQLITE3_INCLUDE_DIR})
