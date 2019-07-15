cmake_minimum_required(VERSION 3.13)

project(w2l_cli)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" )
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Wav2Letter REQUIRED)
find_package(fvad REQUIRED)
find_package(PulseAudio REQUIRED)

add_executable(w2l_cli main.cpp)

# Hack to compute the path to pulseaudio-simple
message(STATUS "Pulseaudio library found at ${PULSEAUDIO_LIBRARY}")
get_filename_component(PULSEAUDIO_ROOT_DIRECTORY ${PULSEAUDIO_LIBRARY} DIRECTORY)

target_link_libraries(w2l_cli
  ${PULSEAUDIO_ROOT_DIRECTORY}/libpulse-simple.so
  ${PULSEAUDIO_LIBRARY}
  ${FVAD_LIBRARIES}
  ${WAV2LETTER_LIBRARIES}
)
