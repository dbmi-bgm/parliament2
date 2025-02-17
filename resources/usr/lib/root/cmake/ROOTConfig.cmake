# ROOT CMake Configuration File for External Projects
# This file is configured by ROOT for use by an external project
# As this file is configured by ROOT's CMake system it SHOULD NOT BE EDITED
# It defines the following variables
#  ROOT_INCLUDE_DIRS - include directories for ROOT
#  ROOT_DEFINITIONS  - compile definitions needed to use ROOT
#  ROOT_LIBRARIES    - libraries to link against
#  ROOT_USE_FILE     - path to a CMake module which may be included to help
#                      setup CMake variables and useful Macros
#
# You may supply a version number through find_package which will be checked
# against the version of this build. Standard CMake logic is used so that
# the EXACT flag may be passed, and otherwise this build will report itself
# as compatible with the requested version if:
#
#  VERSION_OF_THIS_BUILD >= VERSION_REQUESTED
#
#
# If you specify components and use the REQUIRED option to find_package, then
# the module will issue a FATAL_ERROR if this build of ROOT does not have
# the requested component(s). Components are any optional ROOT library, which
# will be added into the ROOT_LIBRARIES variable.
#
# The list of options available generally corresponds to the optional extras
# that ROOT can be built are also made available to the dependent project as
# ROOT_{option}_FOUND
#
#
# ===========================================================================

#----------------------------------------------------------------------------
# DEBUG : print out the variables passed via find_package arguments
#
if(ROOT_CONFIG_DEBUG)
    message(STATUS "ROOTCFG_DEBUG : ROOT_VERSION         = ${ROOT_VERSION}")
    message(STATUS "ROOTCFG_DEBUG : ROOT_FIND_VERSION    = ${ROOT_FIND_VERSION}")
    message(STATUS "ROOTCFG_DEBUG : ROOT_FIND_REQUIRED   = ${ROOT_FIND_REQUIRED}")
    message(STATUS "ROOTCFG_DEBUG : ROOT_FIND_COMPONENTS = ${ROOT_FIND_COMPONENTS}")
    foreach(_cpt ${ROOT_FIND_COMPONENTS})
       message(STATUS "ROOTCFG_DEBUG : ROOT_FIND_REQUIRED_${_cpt} = ${ROOT_FIND_REQUIRED_${_cpt}}")
    endforeach()
endif()

#----------------------------------------------------------------------------
# Locate ourselves, since all other config files should have been installed
# alongside us...
#
get_filename_component(_thisdir "${CMAKE_CURRENT_LIST_FILE}" PATH)

#-----------------------------------------------------------------------
# Provide *recommended* compiler flags used by this build of ROOT
# Don't mess with the actual CMAKE_CXX_FLAGS!!!
# It's up to the user what to do with these
#
set(ROOT_DEFINITIONS "")
set(ROOT_CXX_FLAGS " -pipe -m64 -fsigned-char -fPIC -pthread -std=c++11")
set(ROOT_C_FLAGS " -pipe -m64 -fPIC -pthread")
set(ROOT_fortran_FLAGS " -m64 -std=legacy")
set(ROOT_EXE_LINKER_FLAGS " -rdynamic")

#----------------------------------------------------------------------------
# Configure the path to the ROOT headers, using a relative path if possible.
# This is only known at CMake time, so we expand a CMake supplied variable.
#

# ROOT configured for the install with relative paths, so use these
get_filename_component(ROOT_INCLUDE_DIRS "${_thisdir}/../include" ABSOLUTE)


# ROOT configured for the install with relative paths, so use these
get_filename_component(ROOT_LIBRARY_DIR "${_thisdir}/../lib" ABSOLUTE)


# ROOT configured for the install with relative paths, so use these
get_filename_component(ROOT_BINARY_DIR "${_thisdir}/../bin" ABSOLUTE)


#----------------------------------------------------------------------------
# Include the file listing all the imported targets and options
if(NOT CMAKE_PROJECT_NAME STREQUAL ROOT)
  include("${_thisdir}/ROOTConfig-targets.cmake")
endif()

#----------------------------------------------------------------------------
# Setup components and options
set(_root_options  asimage astiff builtin_afterimage builtin_fftw3 builtin_freetype builtin_ftgl builtin_gl2ps builtin_glew builtin_gsl builtin_llvm builtin_lzma builtin_pcre builtin_tbb builtin_unuran cling cxx11 exceptions explicitlink fftw3 gdml genvector http imt krb5 mathmore memstat minuit2 opengl pch pythia8 python qt qtgsi roofit shadowpw shared ssl table thread tmva unuran x11 xft xml xrootd)

foreach(_opt ${_root_options})
  set(ROOT_${_opt}_FOUND TRUE)
endforeach()

#----------------------------------------------------------------------------
# Now set them to ROOT_LIBRARIES
set(ROOT_LIBRARIES)
foreach(_cpt Core RIO Net Hist Graf Graf3d Gpad Tree Rint Postscript Matrix Physics MathCore Thread MultiProc ${ROOT_FIND_COMPONENTS})
  find_library(ROOT_${_cpt}_LIBRARY ${_cpt} HINTS ${ROOT_LIBRARY_DIR})
  if(ROOT_${_cpt}_LIBRARY)
    mark_as_advanced(ROOT_${_cpt}_LIBRARY)
    list(APPEND ROOT_LIBRARIES ${ROOT_${_cpt}_LIBRARY})
    list(REMOVE_ITEM ROOT_FIND_COMPONENTS ${_cpt})
  endif()
endforeach()
if(ROOT_LIBRARIES)
  list(REMOVE_DUPLICATES ROOT_LIBRARIES)
endif()

#----------------------------------------------------------------------------
# Locate the tools
set(ROOT_ALL_TOOLS genreflex genmap root rootcint rootcling hadd rootls rootrm rootmv rootmkdir rootcp rootdraw rootbrowse)
foreach(_cpt ${ROOT_ALL_TOOLS})
  if(NOT ROOT_${_cpt}_CMD)
    find_program(ROOT_${_cpt}_CMD ${_cpt} HINTS ${ROOT_BINARY_DIR})
    if(ROOT_${_cpt}_CMD)
      mark_as_advanced(ROOT_${_cpt}_CMD)
    endif()
  endif()
endforeach()

#----------------------------------------------------------------------------
set(ROOT_EXECUTABLE ${ROOT_root_CMD})

#----------------------------------------------------------------------------
# Point the user to the ROOTUseFile.cmake file which they may wish to include
# to help them with setting up ROOT
#
set(ROOT_USE_FILE ${_thisdir}/ROOTUseFile.cmake)

#----------------------------------------------------------------------------
# Finally, handle any remaining components.
# We should have dealt with all available components above, and removed them
# from the list of FIND_COMPONENTS so any left we either didn't find or don't
# know about. Emit a warning if REQUIRED isn't set, or FATAL_ERROR otherwise
#
list(REMOVE_DUPLICATES ROOT_FIND_COMPONENTS)
foreach(_remaining ${ROOT_FIND_COMPONENTS})
    if(ROOT_FIND_REQUIRED_${_remaining})
        message(FATAL_ERROR "ROOT component ${_remaining} not found")
    elseif(NOT ROOT_FIND_QUIETLY)
        message(WARNING " ROOT component ${_remaining} not found")
    endif()
    unset(ROOT_FIND_REQUIRED_${_remaining})
endforeach()
