typedef struct m1m3_Support_cache {
  int cppDummy;
  int syncI;
  char private_revCode[32];
  long private_sndStamp;
  long private_rcvStamp;
  long private_seqNum;
  long private_origin;
  long Raw[16];
  float Calibrated[32];
  char Status[16];
  int syncO;
} m1m3_Support_cache;
