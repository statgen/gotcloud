# ==========================
# Premo 
# (c) 2012 Derek Barnett
#
# src/libs/jsoncpp
# ==========================

# add compiler definitions 
add_definitions( -DJSONCPP_LIBRARY ) # (for proper exporting of library symbols)
add_definitions( -fPIC ) # (attempt to force PIC compiling on CentOS, not being set on shared libs by CMake)

# create jsoncpp library
add_library( jsoncpp SHARED
             json_reader.cpp
             json_value.cpp
             json_writer.cpp
           )

# set jsoncpp library properties
set_target_properties( jsoncpp PROPERTIES
                       SOVERSION   1.0.0
                       OUTPUT_NAME jsoncpp
                     )

include( ${Premo_SOURCE_DIR}/src/libs/ExportHeader.cmake )
set( JsonCppIncludeDir "jsoncpp" )
ExportHeader(JsonCppHeaders json.h                ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_batchallocator.h ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_config.h         ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_features.h       ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_forwards.h       ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_reader.h         ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_tool.h           ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_value.h          ${JsonCppIncludeDir})
ExportHeader(JsonCppHeaders json_writer.h         ${JsonCppIncludeDir})
