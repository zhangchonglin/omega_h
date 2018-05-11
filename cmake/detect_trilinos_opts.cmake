if(DETECT_TRILINOS_OPTS)
  return()
endif()
set(DETECT_TRILINOS_OPTS true)

function(detect_trilinos_opts)
  if (KokkosCore_FOUND)
    set(FILE_FOUND FALSE)
    foreach(INC_DIR IN LISTS KokkosCore_INCLUDE_DIRS)
      if (EXISTS "${INC_DIR}/KokkosCore_config.h")
        set(FILE_FOUND TRUE)
        message(STATUS "Found ${INC_DIR}/KokkosCore_config.h")
        file(READ "${INC_DIR}/KokkosCore_config.h" CONTENTS)
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_HAVE_CUDA")
          message(STATUS "KokkosCore has CUDA")
          set(KokkosCore_HAS_CUDA TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_ENABLE_CUDA")
          message(STATUS "KokkosCore has CUDA")
          set(KokkosCore_HAS_CUDA TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_HAVE_OPENMP")
          message(STATUS "KokkosCore has OpenMP")
          set(KokkosCore_HAS_OpenMP TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_ENABLE_OPENMP")
          message(STATUS "KokkosCore has OpenMP")
          set(KokkosCore_HAS_OpenMP TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_HAVE_CUDA_LAMBDA")
          message(STATUS "KokkosCore has CUDA lambdas")
          set(KokkosCore_HAS_CUDA_LAMBDA TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_CUDA_USE_LAMBDA")
          message(STATUS "KokkosCore has CUDA lambdas")
          set(KokkosCore_HAS_CUDA_LAMBDA TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_ENABLE_CUDA_LAMBDA")
          message(STATUS "KokkosCore has CUDA lambdas")
          set(KokkosCore_HAS_CUDA_LAMBDA TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_ENABLE_PROFILING_INTERNAL")
          message(STATUS "KokkosCore has profiling")
          set(KokkosCore_HAS_PROFILING TRUE PARENT_SCOPE)
        endif()
        if ("${CONTENTS}" MATCHES "\n\#define KOKKOS_ENABLE_PROFILING")
          message(STATUS "KokkosCore has profiling")
          set(KokkosCore_HAS_PROFILING TRUE PARENT_SCOPE)
        endif()
      endif()
    endforeach()
    if (NOT FILE_FOUND)
      message(FATAL_ERROR "Couldn't find KokkosCore_config.h")
    endif()
  endif()
  if (TeuchosComm_FOUND)
    list(FIND TeuchosComm_TPL_LIST "MPI" MPI_IDX)
    if (${MPI_IDX} GREATER -1)
      message(STATUS "TeuchosComm has MPI")
      set(TeuchosComm_HAS_MPI TRUE PARENT_SCOPE)
    endif()
  endif()
endfunction(detect_trilinos_opts)
