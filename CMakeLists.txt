cmake_minimum_required(VERSION 3.16)

project(ScriptRunner VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt6 modules
find_package(Qt6 REQUIRED COMPONENTS Quick Core QuickControls2)

# Standard Qt6 project setup (requires Qt 6.8+)
qt_standard_project_setup(REQUIRES 6.8)

# Add executable
qt_add_executable(appScriptRunner
    main.cpp

    mousepositionprovider.h
    srunner.h
    settingsmanager.h
    actionmanager.h

    mousepositionprovider.cpp
    srunner.cpp
    settingsmanager.cpp
    actionmanager.cpp
)

# Set properties for macOS bundle / Windows executable
set_target_properties(appScriptRunner PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Link Qt libraries
target_link_libraries(appScriptRunner
    PRIVATE Qt6::Quick Qt6::Core Qt6::QuickControls2
)

# Install rules
include(GNUInstallDirs)
install(TARGETS appScriptRunner
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
