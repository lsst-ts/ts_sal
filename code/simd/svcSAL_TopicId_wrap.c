/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 1.3.40
 * 
 * This file is not intended to be easily readable and contains a number of 
 * coding conventions designed to improve portability and efficiency. Do not make
 * changes to this file unless you know what you are doing--modify the SWIG 
 * interface file instead. 
 * ----------------------------------------------------------------------------- */

#define SWIGJAVA

/* -----------------------------------------------------------------------------
 *  This section contains generic SWIG labels for method/variable
 *  declarations/attributes, and other compiler dependent labels.
 * ----------------------------------------------------------------------------- */

/* template workaround for compilers that cannot correctly implement the C++ standard */
#ifndef SWIGTEMPLATEDISAMBIGUATOR
# if defined(__SUNPRO_CC) && (__SUNPRO_CC <= 0x560)
#  define SWIGTEMPLATEDISAMBIGUATOR template
# elif defined(__HP_aCC)
/* Needed even with `aCC -AA' when `aCC -V' reports HP ANSI C++ B3910B A.03.55 */
/* If we find a maximum version that requires this, the test would be __HP_aCC <= 35500 for A.03.55 */
#  define SWIGTEMPLATEDISAMBIGUATOR template
# else
#  define SWIGTEMPLATEDISAMBIGUATOR
# endif
#endif

/* inline attribute */
#ifndef SWIGINLINE
# if defined(__cplusplus) || (defined(__GNUC__) && !defined(__STRICT_ANSI__))
#   define SWIGINLINE inline
# else
#   define SWIGINLINE
# endif
#endif

/* attribute recognised by some compilers to avoid 'unused' warnings */
#ifndef SWIGUNUSED
# if defined(__GNUC__)
#   if !(defined(__cplusplus)) || (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4))
#     define SWIGUNUSED __attribute__ ((__unused__)) 
#   else
#     define SWIGUNUSED
#   endif
# elif defined(__ICC)
#   define SWIGUNUSED __attribute__ ((__unused__)) 
# else
#   define SWIGUNUSED 
# endif
#endif

#ifndef SWIG_MSC_UNSUPPRESS_4505
# if defined(_MSC_VER)
#   pragma warning(disable : 4505) /* unreferenced local function has been removed */
# endif 
#endif

#ifndef SWIGUNUSEDPARM
# ifdef __cplusplus
#   define SWIGUNUSEDPARM(p)
# else
#   define SWIGUNUSEDPARM(p) p SWIGUNUSED 
# endif
#endif

/* internal SWIG method */
#ifndef SWIGINTERN
# define SWIGINTERN static SWIGUNUSED
#endif

/* internal inline SWIG method */
#ifndef SWIGINTERNINLINE
# define SWIGINTERNINLINE SWIGINTERN SWIGINLINE
#endif

/* exporting methods */
#if (__GNUC__ >= 4) || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4)
#  ifndef GCC_HASCLASSVISIBILITY
#    define GCC_HASCLASSVISIBILITY
#  endif
#endif

#ifndef SWIGEXPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORT
#   else
#     define SWIGEXPORT __declspec(dllexport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGEXPORT __attribute__ ((visibility("default")))
#   else
#     define SWIGEXPORT
#   endif
# endif
#endif

/* calling conventions for Windows */
#ifndef SWIGSTDCALL
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   define SWIGSTDCALL __stdcall
# else
#   define SWIGSTDCALL
# endif 
#endif

/* Deal with Microsoft's attempt at deprecating C standard runtime functions */
#if !defined(SWIG_NO_CRT_SECURE_NO_DEPRECATE) && defined(_MSC_VER) && !defined(_CRT_SECURE_NO_DEPRECATE)
# define _CRT_SECURE_NO_DEPRECATE
#endif

/* Deal with Microsoft's attempt at deprecating methods in the standard C++ library */
#if !defined(SWIG_NO_SCL_SECURE_NO_DEPRECATE) && defined(_MSC_VER) && !defined(_SCL_SECURE_NO_DEPRECATE)
# define _SCL_SECURE_NO_DEPRECATE
#endif



/* Fix for jlong on some versions of gcc on Windows */
#if defined(__GNUC__) && !defined(__INTEL_COMPILER)
  typedef long long __int64;
#endif

/* Fix for jlong on 64-bit x86 Solaris */
#if defined(__x86_64)
# ifdef _LP64
#   undef _LP64
# endif
#endif

#include <jni.h>
#include <stdlib.h>
#include <string.h>


/* Support for throwing Java exceptions */
typedef enum {
  SWIG_JavaOutOfMemoryError = 1, 
  SWIG_JavaIOException, 
  SWIG_JavaRuntimeException, 
  SWIG_JavaIndexOutOfBoundsException,
  SWIG_JavaArithmeticException,
  SWIG_JavaIllegalArgumentException,
  SWIG_JavaNullPointerException,
  SWIG_JavaDirectorPureVirtual,
  SWIG_JavaUnknownError
} SWIG_JavaExceptionCodes;

typedef struct {
  SWIG_JavaExceptionCodes code;
  const char *java_exception;
} SWIG_JavaExceptions_t;


static void SWIGUNUSED SWIG_JavaThrowException(JNIEnv *jenv, SWIG_JavaExceptionCodes code, const char *msg) {
  jclass excep;
  static const SWIG_JavaExceptions_t java_exceptions[] = {
    { SWIG_JavaOutOfMemoryError, "java/lang/OutOfMemoryError" },
    { SWIG_JavaIOException, "java/io/IOException" },
    { SWIG_JavaRuntimeException, "java/lang/RuntimeException" },
    { SWIG_JavaIndexOutOfBoundsException, "java/lang/IndexOutOfBoundsException" },
    { SWIG_JavaArithmeticException, "java/lang/ArithmeticException" },
    { SWIG_JavaIllegalArgumentException, "java/lang/IllegalArgumentException" },
    { SWIG_JavaNullPointerException, "java/lang/NullPointerException" },
    { SWIG_JavaDirectorPureVirtual, "java/lang/RuntimeException" },
    { SWIG_JavaUnknownError,  "java/lang/UnknownError" },
    { (SWIG_JavaExceptionCodes)0,  "java/lang/UnknownError" }
  };
  const SWIG_JavaExceptions_t *except_ptr = java_exceptions;

  while (except_ptr->code != code && except_ptr->code)
    except_ptr++;

  (*jenv)->ExceptionClear(jenv);
  excep = (*jenv)->FindClass(jenv, except_ptr->java_exception);
  if (excep)
    (*jenv)->ThrowNew(jenv, excep, msg);
}


/* Contract support */

#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) {SWIG_JavaThrowException(jenv, SWIG_JavaIllegalArgumentException, msg); return nullreturn; } else


typedef unsigned short uShortArray;

SWIGINTERN uShortArray *new_uShortArray(int nelements){
  return (unsigned short *) calloc(nelements,sizeof(unsigned short));
}
SWIGINTERN void delete_uShortArray(uShortArray *self){
  free(self);
}
SWIGINTERN unsigned short uShortArray_getitem(uShortArray *self,int index){
  return self[index];
}
SWIGINTERN void uShortArray_setitem(uShortArray *self,int index,unsigned short value){
  self[index] = value;
}
SWIGINTERN unsigned short *uShortArray_cast(uShortArray *self){
  return self;
}
SWIGINTERN uShortArray *uShortArray_frompointer(unsigned short *t){
  return (uShortArray *) t;
}


#include "svcSAL.h"

class salTopicId
{
public:
        salTopiId();
        ~salTopicId();

	svcRTN checkStatus ();
	svcRTN getSample (svcINT timeout);
	svcRTN putSample ();
	svcRTN getItem ( svcNAME *item , svcSHORT &value );
	svcRTN getItem ( svcNAME *item , svcUSHORT &value );
	svcRTN getItem ( svcNAME *item , svcINT &value );
	svcRTN getItem ( svcNAME *item , svcUINT &value );
	svcRTN getItem ( svcNAME *item , svcFLT &fvalue );
	svcRTN getItem ( svcNAME *item , svcDBL &dvalue );
	svcRTN getItem ( svcNAME *item , svcSHORT &value , svcINT size );
	svcRTN getItem ( svcNAME *item , svcUSHORT &value, svcINT size );
	svcRTN getItem ( svcNAME *item , svcINT &value , svcINT size );
	svcRTN getItem ( svcNAME *item , svcUINT &value, svcINT size );
	svcRTN getItem ( svcNAME *item , svcFLT &fvalue, svcINT size );
	svcRTN getItem ( svcNAME *item , svcDBL &dvalue, svcINT size);
        svcRTN getItem ( svcNAME *itemName , svcCHAR *textValue);
	
	svcRTN putItem ( svcNAME *item , svcSHORT &value );
	svcRTN putItem ( svcNAME *item , svcUSHORT &value );
	svcRTN putItem ( svcNAME *item , svcINT &value );
	svcRTN putItem ( svcNAME *item , svcUINT &value );
	svcRTN putItem ( svcNAME *item , svcFLT &fvalue );
	svcRTN putItem ( svcNAME *item , svcDBL &dvalue );
	svcRTN putItem ( svcNAME *item , svcSHORT &value , svcINT size );
	svcRTN putItem ( svcNAME *item , svcUSHORT &value, svcINT size );
	svcRTN putItem ( svcNAME *item , svcINT &value , svcINT size );
	svcRTN purItem ( svcNAME *item , svcUINT &value, svcINT size );
	svcRTN putItem ( svcNAME *item , svcFLT &fvalue, svcINT size );
	svcRTN putItem ( svcNAME *item , svcDBL &dvalue, svcINT size);
        svcRTN putItem ( svcNAME *itemName , svcCHAR *textValue);

        svcRTN getProperty ( svcNAME *propertyName , svcCHAR *textValue);
        svcRTN setProperty ( svcNAME *propertyName , svcCHAR *textValue);
	
private:
	void *currentInstance= NULL;
        svcINT newData = SAL__NO_UPDATES;
	svtINT debugLevel;
        svcTIME timeOfSnd;
        svcTIME timeOfRcv;
	svcINT haveDur;
	svcINT haveRdr;
	svcINT haveWrt;
	svcINT readCount;
	svcINT writeCount;
	svcINT setHistoryDepth ( svcInt depth);
	svcINT setAutoDispose ( svcBool state);
	svcINT setQos (svcCHAR *parameter , svcCHAR value);
	svcINT priority;
	svcINT pid;
	dds::TopicQos tqos;
	dds::SampleInfo sinfo;
	dds::DataWriterQos wQos(dds::TopicQos Qos);
	dds::DataReaderQos rQos(dds::TopicQos Qos);
	dds::Duration latency_budget;
	dds::deadline;
	TopicId data;
	

};



#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORT jlong JNICALL Java_svcSAL_1TopicIdJNI_new_1uShortArray(JNIEnv *jenv, jclass jcls, jint jarg1) {
  jlong jresult = 0 ;
  int arg1 ;
  uShortArray *result = 0 ;
  
  (void)jenv;
  (void)jcls;
  arg1 = (int)jarg1; 
  result = (uShortArray *)new_uShortArray(arg1);
  *(uShortArray **)&jresult = result; 
  return jresult;
}


SWIGEXPORT void JNICALL Java_svcSAL_1TopicIdJNI_delete_1uShortArray(JNIEnv *jenv, jclass jcls, jlong jarg1) {
  uShortArray *arg1 = (uShortArray *) 0 ;
  
  (void)jenv;
  (void)jcls;
  arg1 = *(uShortArray **)&jarg1; 
  delete_uShortArray(arg1);
}


SWIGEXPORT jint JNICALL Java_svcSAL_1TopicIdJNI_uShortArray_1getitem(JNIEnv *jenv, jclass jcls, jlong jarg1, jobject jarg1_, jint jarg2) {
  jint jresult = 0 ;
  uShortArray *arg1 = (uShortArray *) 0 ;
  int arg2 ;
  unsigned short result;
  
  (void)jenv;
  (void)jcls;
  (void)jarg1_;
  arg1 = *(uShortArray **)&jarg1; 
  arg2 = (int)jarg2; 
  result = (unsigned short)uShortArray_getitem(arg1,arg2);
  jresult = (jint)result; 
  return jresult;
}


SWIGEXPORT void JNICALL Java_svcSAL_1TopicIdJNI_uShortArray_1setitem(JNIEnv *jenv, jclass jcls, jlong jarg1, jobject jarg1_, jint jarg2, jint jarg3) {
  uShortArray *arg1 = (uShortArray *) 0 ;
  int arg2 ;
  unsigned short arg3 ;
  
  (void)jenv;
  (void)jcls;
  (void)jarg1_;
  arg1 = *(uShortArray **)&jarg1; 
  arg2 = (int)jarg2; 
  arg3 = (unsigned short)jarg3; 
  uShortArray_setitem(arg1,arg2,arg3);
}


SWIGEXPORT jlong JNICALL Java_svcSAL_1TopicIdJNI_uShortArray_1cast(JNIEnv *jenv, jclass jcls, jlong jarg1, jobject jarg1_) {
  jlong jresult = 0 ;
  uShortArray *arg1 = (uShortArray *) 0 ;
  unsigned short *result = 0 ;
  
  (void)jenv;
  (void)jcls;
  (void)jarg1_;
  arg1 = *(uShortArray **)&jarg1; 
  result = (unsigned short *)uShortArray_cast(arg1);
  *(unsigned short **)&jresult = result; 
  return jresult;
}


SWIGEXPORT jlong JNICALL Java_svcSAL_1TopicIdJNI_uShortArray_1frompointer(JNIEnv *jenv, jclass jcls, jlong jarg1) {
  jlong jresult = 0 ;
  unsigned short *arg1 = (unsigned short *) 0 ;
  uShortArray *result = 0 ;
  
  (void)jenv;
  (void)jcls;
  arg1 = *(unsigned short **)&jarg1; 
  result = (uShortArray *)uShortArray_frompointer(arg1);
  *(uShortArray **)&jresult = result; 
  return jresult;
}


#ifdef __cplusplus
}
#endif

