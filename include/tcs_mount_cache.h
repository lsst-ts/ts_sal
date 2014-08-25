typedef struct tcs_mount_cache {
  int cppDummy;
  int syncI;
  int syncO;
  char private_revCode[32];
  long private_sndStamp;
  long private_rcvStamp;
  long private_seqNum;
  long private_origin;
  float az;
  float el;
  float zdist;
  float raenc;
  float decenc;
  float racoll;
  float deccoll;
  float focenc;
  float focus;
  float scale;
  float rguide;
  float rset;
  float rsearch;
  char ra[16];
  char dec[16];
  char ha[16];
  char state[16];
  char foci[16];
} tcs_mount_cache;
