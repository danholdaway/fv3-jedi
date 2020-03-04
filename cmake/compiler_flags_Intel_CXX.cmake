# (C) Copyright 2009-2016 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation nor
# does it submit to any jurisdiction.

####################################################################
# FLAGS COMMON TO ALL BUILD TYPES
####################################################################

####################################################################
# RELEASE FLAGS
####################################################################

set( CMAKE_CXX_FLAGS_RELEASE     "-O3 -std=c++17" )

####################################################################
# DEBUG FLAGS
####################################################################

set( CMAKE_CXX_FLAGS_DEBUG       "-O0 -g -traceback -fp-trap=common -std=c++17" )

####################################################################
# BIT REPRODUCIBLE FLAGS
####################################################################

set( CMAKE_CXX_FLAGS_BIT         "-O2 -std=c++17" )

####################################################################
# LINK FLAGS
####################################################################

set( CMAKE_CXX_LINK_FLAGS        "" )

####################################################################

# Meaning of flags
# ----------------
# todo

