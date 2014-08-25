typedef struct tcs_guider_cache {
  int cppDummy;
  int syncI;
  int syncO;
  char private_revCode[32];
  long private_sndStamp;
  long private_rcvStamp;
  long private_seqNum;
  long private_origin;
  float probex;
  float probey;
  float focus;
  char ra[16];
  char dec[16];
  char state[16];
  float centx;
  float centy;
  float fwhm;
  float xcorr;
  float ycorr;
  float racorr;
  float deccorr;
  float leak;
  float gain;
} tcs_guider_cache;
