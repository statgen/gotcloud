# ==========================
# Premo
# (c) 2012 Derek Barnett
#
# src/app
# ==========================

# set include path
include_directories( ${Premo_SOURCE_DIR}/include
                     ${Premo_SOURCE_DIR}/include/bamtools
                     ${Premo_SOURCE_DIR}/include/jsoncpp
                     ${Premo_SOURCE_DIR}/src/libs
                   )

# compile main premo application
add_executable( PremoApp
                batch.cpp
                fastq.cpp
                fastqreader.cpp
                fastqwriter.cpp
                main.cpp
                options.cpp
                pebatch.cpp
                premo.cpp
                sebatch.cpp
              )

# set Premo application properties
set_target_properties( PremoApp PROPERTIES
                       VERSION  0.2.0
                       OUTPUT_NAME "premo"
                     )
# make version info available in application
configure_file( premo_version.h.in ${Premo_SOURCE_DIR}/src/app/premo_version.h )

# define libraries to link
target_link_libraries( PremoApp BamTools jsoncpp z )

# set application install destinations
install( TARGETS PremoApp DESTINATION "bin")
