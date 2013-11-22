# ==========================
# Premo
# (c) 2012 Derek Barnett
#
# src/libs/bamtools/api/internal/sam
# ==========================

set ( InternalSamDir "${InternalDir}/sam" )

set ( InternalSamSources
        ${InternalSamDir}/SamFormatParser_p.cpp
        ${InternalSamDir}/SamFormatPrinter_p.cpp
        ${InternalSamDir}/SamHeaderValidator_p.cpp

        PARENT_SCOPE # <-- leave this last
)

