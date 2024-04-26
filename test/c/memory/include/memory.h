// #pragma once

#ifdef __cplusplus
#define EXTERN_C extern "C"
#else
#define EXTERN_C
#endif


#if defined(__CYGWIN__)
#elif defined(_WIN32)
  #if defined(SHARED_LIB)
    #define EXPORT EXTERN_C __declspec(dllexport)
  #else
    #define EXPORT EXTERN_C
  #endif
#else
  #if __GNUC__ >= 4
    #if defined(SHARED_LIB)
      #define EXPORT                                                            \
        EXTERN_C __attribute__((visibility("default"))) __attribute((used))
    #else
      #define EXPORT EXTERN_C
    #endif
  #else
    #error Tool chain not supported.
  #endif
#endif


EXPORT void* myCalloc(size_t num, size_t size);

EXPORT void myFree(void* ptr);