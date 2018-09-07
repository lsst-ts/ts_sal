set SHC(genericshmem.h) "
#ifndef __[set subsys]_H__
#define __[set subsys]_H__
#include \"[set subsys]_cache.h\"

class shm_[set subsys]\
\{
   public:
     shm_[set subsys]();
     virtual void Handle();
     void GetObject( [set subsys]_cache *pshm);

[set TOPICPROPS($subsys)]
     static shm_[set subsys] m_sInitializer;
     int m_[set subsys]_shmid;
     [set subsys]_cache *m_shared_mem;
     [set subsys]_cache *data;
\};




#endif //__[set subsys]_H__
"

