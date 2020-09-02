/*
 * (C) Copyright 2020 UCAR
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 */

#pragma once

namespace eckit {
  class Configuration;
}

namespace fv3jedi {
  typedef int F90vc_VR;
  extern "C" {
    void fv3jedi_vc_vertremap_create_f90(const F90vc_VR &, const F90geom &,
                                         const eckit::Configuration * const *);
    void fv3jedi_vc_vertremap_delete_f90(F90vc_VR &);
    void fv3jedi_vc_vertremap_changevar_f90(const F90vc_VR &, const F90state &,
                                            const F90state &);
  }  // extern "C"
}  // namespace fv3jedi
