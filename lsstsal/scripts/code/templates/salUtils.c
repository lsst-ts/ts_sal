#include <time.h>
#include <sys/time.h>
#include <sys/timex.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include "org_lsst_sal_salUtils.h"

JNIEXPORT jint JNICALL Java_org_lsst_sal_salUtils_getLeapSeconds
  (JNIEnv *env, jobject obj) {
   struct timex tx;

   memset(&tx, 0, sizeof(tx));
   adjtimex(&tx);
   return tx.tai;
}

JNIEXPORT jdouble JNICALL Java_org_lsst_sal_salUtils_getTAISeconds
  (JNIEnv *env, jobject obj) {
   struct timex tx;
   struct timespec now;
   double taiTime;

   memset(&tx, 0, sizeof(tx));
   adjtimex(&tx);
   clock_gettime(CLOCK_TAI,&now);
   taiTime = (double)now.tv_sec + (double)now.tv_nsec/1000000000.;
   return taiTime;
}

JNIEXPORT jdouble JNICALL Java_org_lsst_sal_salUtils_getUTCSeconds
  (JNIEnv *env, jobject obj) {
   struct timex tx;
   struct timespec now;
   double utcTime;

   clock_gettime(CLOCK_REALTIME,&now);
   utcTime = (double)now.tv_sec + (double)now.tv_nsec/1000000000.;
   return utcTime;
}

