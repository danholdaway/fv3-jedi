# (C) Copyright 2017-2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

# ##########
# fv3-bundle
# ##########

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

project( fv3-bundle VERSION 1.0.0 LANGUAGES C CXX Fortran )

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include( ecbuild_bundle )

# Default release mode
set( ECBUILD_DEFAULT_BUILD_TYPE Release )

# Enable MPI
set( ENABLE_MPI ON CACHE BOOL "Compile with MPI" )

# Initialize
ecbuild_bundle_initialize()
ecbuild_bundle( PROJECT jedicmake GIT "https://github.com/jcsda-internal/jedi-cmake.git" )
include( jedicmake/cmake/Functions/git_functions.cmake  )

# ECMWF libs
# ----------
option("BUNDLE_SKIP_ECKIT" "Don't build eckit" "ON" ) # Skip eckit build unless user passes -DBUNDLE_SKIP_ECKIT=OFF
option("BUNDLE_SKIP_FCKIT" "Don't build fckit" "ON") # Skip eckit build unless user passes -DBUNDLE_SKIP_FCKIT=OFF
option("BUNDLE_SKIP_ATLAS" "Don't build atlas" "ON") #Skip eckit build unless user passes -DBUNDLE_SKIP_ATLAS=OFF

ecbuild_bundle( PROJECT eckit GIT "https://github.com/jcsda-internal/eckit.git" )
ecbuild_bundle( PROJECT fckit GIT "https://github.com/jcsda-internal/fckit.git" )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/jcsda-internal/atlas.git" )

# External (optional) observation operators
# ------------------------------
option("BUNDLE_SKIP_GEOS-AERO" "Don't build GEOS-AERO" "ON") # Skip geos-aero build unless user passes -DBUNDLE_SKIP_GEOS-AERO=OFF
option("BUNDLE_SKIP_GSW"       "Don't build GSW"       "ON") # Skip gsw build unless user passes -DBUNDLE_SKIP_GSW=OFF
option("BUNDLE_SKIP_ROPP-UFO"  "Don't build ROPP-UFO"  "ON") # Skip ropp-ufo build unless user passes -DBUNDLE_SKIP_ROPP-UFO=OFF

ecbuild_bundle( PROJECT geos-aero GIT "https://github.com/jcsda-internal/geos-aero.git" )
ecbuild_bundle( PROJECT gsw GIT "https://github.com/jcsda-internal/GSW-Fortran.git" )
ecbuild_bundle( PROJECT ropp-ufo GIT "https://github.com/jcsda-internal/ropp-test.git" )

# External (required) observation operators
# ------------------------------
option("BUNDLE_SKIP_CRTM" "Don't build CRTM" "OFF") # Skip crtm build unless user passes -DBUNDLE_SKIP_CRTM=ON
ecbuild_bundle( PROJECT crtm GIT "https://github.com/jcsda-internal/crtm.git" )

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda-internal/oops.git" )
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda-internal/saber.git" )
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda-internal/ioda.git" )
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda-internal/ufo.git" )

# Options for building with certain models
# ----------------------------------------
set(FV3_FORECAST_MODEL "FV3CORE" CACHE STRING "Choose which MODEL to build with")
set_property(CACHE FV3_FORECAST_MODEL PROPERTY STRINGS "FV3CORE" "UFS" "GEOS")
if(NOT FV3_FORECAST_MODEL MATCHES "^(FV3CORE|UFS|GEOS)$")
  ecbuild_error("Valid options for -DFV3_FORECAST_MODEL are FV3CORE|UFS|GEOS")
endif()
ecbuild_info("Building with FV3-based model: ${FV3_FORECAST_MODEL}")

# FMS and FV3 dynamical core model are needed for FV3CORE
# -------------------------------------------------------
if (FV3_FORECAST_MODEL MATCHES "FV3CORE")
  option("BUNDLE_SKIP_FMS" "Don't build FMS" "OFF")
  ecbuild_bundle( PROJECT fms GIT "https://github.com/jcsda-internal/FMS.git" )
  ecbuild_bundle( PROJECT fv3 GIT "https://github.com/jcsda-internal/GFDL_atmos_cubed_sphere.git" )
endif()

# fv3-jedi linear model
# ---------------------
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda-internal/fv3-jedi-linearmodel.git" )

# fv3-jedi and associated repositories
# ------------------------------------
ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda-internal/femps.git" )
ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda-internal/fv3-jedi.git" )

# ioda, ufo, and fv3-jedi test data
#---------------------------------

# If IODA branch is being built set GIT_BRANCH_FUNC to IODA's current branch.
# If a tagged version of IODA is being built set GIT_TAG_FUNC to ioda's current tag. In this case,
# IODA test files will be download from UCAR DASH and ioda-data repo will not be cloned.
# When LOCAL_PATH_JEDI_TESTFILES is set to the directory of IODA test files stored
# in a local directory, ioda-data repo will not be cloned

# same procedure for fv3-jedi-data
find_branch_name(REPO_DIR_NAME fv3-jedi)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED ${GIT_TAG_FUNC} )
  ecbuild_bundle( PROJECT fv3-jedi-data GIT "https://github.com/JCSDA-internal/fv3-jedi-data.git" )
endif()

# Build Doxygen documentation
# ---------------------------
option(BUILD_FV3_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_FV3_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif(BUILD_FV3_BUNDLE_DOC)

ecbuild_bundle_finalize()

include(cmake/cdash-integration.cmake)
include(CTest)
