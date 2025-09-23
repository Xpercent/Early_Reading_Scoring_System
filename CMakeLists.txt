cmake_minimum_required(VERSION 3.16)

project(Early_Reading_Scoring_System VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)


file(GLOB_RECURSE OTHER_FILES CONFIGURE_DEPENDS "page/*.qml")
source_group("page" FILES ${OTHER_FILES})
qt_add_executable(appEarly_Reading_Scoring_System
    main.cpp
    icon.rc
    ${OTHER_FILES}
)

##########
#只是让编辑器显示这些文件以方便更改
# add_custom_target(ide_display_files
#     DEPENDS ${OTHER_FILES}
#     COMMENT "Dummy target for showing non-compiled files in the IDE"
# )
# set_property(TARGET ide_display_files PROPERTY SOURCES ${OTHER_FILES})
# set_target_properties(ide_display_files PROPERTIES FOLDER "辅助文件")
##########

# 移除内嵌QML模块，纯C++可执行程序，运行时从文件系统加载QML
target_sources(appEarly_Reading_Scoring_System PRIVATE globalfunc.h globalfunc.cpp)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# ... (省略了一些注释)
set_target_properties(appEarly_Reading_Scoring_System PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appEarly_Reading_Scoring_System
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appEarly_Reading_Scoring_System
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appEarly_Reading_Scoring_System
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 确保每次构建都复制资源文件
add_custom_target(copy_resources ALL
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/resources
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/page
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/resources ${CMAKE_BINARY_DIR}/resources
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/page ${CMAKE_BINARY_DIR}/page
    COMMENT "Copying resources and QML files to build directory"
)
