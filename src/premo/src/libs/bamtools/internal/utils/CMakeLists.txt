# ==========================
# Premo
# (c) 2012 Derek Barnett
#
# src/libs/bamtools/api/internal/utils
# ==========================

set ( InternalUtilsDir "${InternalDir}/utils" )

set ( InternalUtilsSources
        ${InternalUtilsDir}/BamException_p.cpp

        PARENT_SCOPE # <-- leave this last
)

