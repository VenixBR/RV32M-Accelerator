
#-----------------------------------------------------------------------------
# Common path variables (directory structure dependent)
#-----------------------------------------------------------------------------
set SYNT_DIR ${PROJECT_DIR}/Synthesis
set SCRIPT_DIR ${SYNT_DIR}/scripts
set RPT_DIR ${SYNT_DIR}/reports
set DEV_DIR ${SYNT_DIR}/deliverables

#-----------------------------------------------------------------------------
# Setting rtl search directories
#-----------------------------------------------------------------------------
set FRONTEND_DIR ${PROJECT_DIR}/src/core
set HDL_DIR ${PROJECT_DIR}/src/core
set OTHERS ""
lappend FRONTEND_DIR $OTHERS

#-----------------------------------------------------------------------------
# Setting technology directories
#-----------------------------------------------------------------------------
set LIB_DIR ${TECH_DIR}/gsclib045_svt_v4.4/gsclib045/timing
#lappend LIB_DIR ${TECH_DIR}/io

set LEF_DIR ${TECH_DIR}/gsclib045_svt_v4.4/gsclib045/lef
lappend LEF_DIR ${TECH_DIR}/giolib045_v3.3/lef



