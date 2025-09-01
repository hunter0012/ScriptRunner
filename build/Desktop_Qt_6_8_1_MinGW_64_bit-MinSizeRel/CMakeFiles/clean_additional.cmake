# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "MinSizeRel")
  file(REMOVE_RECURSE
  "CMakeFiles\\appScriptRunner_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appScriptRunner_autogen.dir\\ParseCache.txt"
  "appScriptRunner_autogen"
  )
endif()
