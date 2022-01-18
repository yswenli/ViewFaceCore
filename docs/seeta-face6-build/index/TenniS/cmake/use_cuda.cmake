# Use CUDA

# if (NOT CUDA_HAS_FP16)
#     message(FATAL_ERROR "CUDA: use version greater 7.5, to support float16")
# endif()

if (${CUDA_VERSION} VERSION_LESS "7.0")
   message(FATAL_ERROR "CUDA: verison must greater than 7.0, found ${CUDA_VERSION}")
endif()

set(TS_NO_FP16 OFF)

set(CUDA_ARCH)
if (TS_CUDA_ARCH)
   message(STATUS "    CUDA: support in ${TS_CUDA_ARCH}")
   string(REPLACE "," ";" ARCH_LIST ${TS_CUDA_ARCH})

   foreach (ARCH ${ARCH_LIST})
       string(STRIP ${ARCH} ARCH)
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_${ARCH},code=sm_${ARCH}")
       if (${ARCH} VERSION_LESS "53")
           set(TS_NO_FP16 ON)
       endif()
   endforeach ()
else(TS_CUDA_ARCH)
   message(STATUS "    CUDA: support Maxwell in 5.3")
   set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_53,code=sm_53")

   if (${CUDA_VERSION} VERSION_GREATER "7.999")
       message(STATUS "    CUDA: support Pascal in 6.0")
       message(STATUS "    CUDA: support Pascal in 6.1")
       message(STATUS "    CUDA: support Pascal in 6.2")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_60,code=sm_60")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_61,code=sm_61")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_62,code=sm_62")
   endif()

   if (${CUDA_VERSION} VERSION_GREATER "8.999")
       message(STATUS "    CUDA: support Volta in 7.0")
       message(STATUS "    CUDA: support Volta in 7.2")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_70,code=sm_70")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_72,code=sm_72")
   endif()

   if (${CUDA_VERSION} VERSION_GREATER "9.999")
       message(STATUS "    CUDA: support Turing in 7.5")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_75,code=sm_75")
   endif()
   if (${CUDA_VERSION} VERSION_GREATER "10.999")
       message(STATUS "    CUDA: support Ampere in 8.0")
       set(CUDA_ARCH "${CUDA_ARCH} -gencode arch=compute_80,code=sm_80")
   endif()
endif(TS_CUDA_ARCH)

if (${CUDA_VERSION} VERSION_GREATER "8.999")
    if (TS_NO_FP16)
        message(STATUS "    CUDA: arch ${TS_CUDA_ARCH} conatins no float16 support, less than 53.")
    else ()
        add_definitions(-DTS_USE_CUDA_FP16)
        message(STATUS "    CUDA: with float16 supporting.")
    endif()
else()
    message(STATUS "    CUDA: no float16 supported.")
endif()

if (MSVC)
    set(CUDA_PROPAGATE_HOST_FLAGS ON)
else ()
    set(CUDA_PROPAGATE_HOST_FLAGS OFF)
endif ()

set(CUDA_NVCC_FLAGS)
set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} ${CUDA_ARCH}")

if (MSVC)
else()
    set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -std=c++11")
    if ("${CONFIGURATION}" STREQUAL "Debug")
       set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -O0 -g")
    else()
       set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -O3")
    endif()
endif()
