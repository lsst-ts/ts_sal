set SHC(genericshmem.cpp) "

#include <sys/types.h>
#include <sys/ipc.h>

#include <sys/shm.h>
#include <errno.h>
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
using namespace std;

#include \"shmem_[set subsys].h\"


void shm_[set subsys]::Handle() \{
       cout <<  \"Object type: shm_[set subsys]\" <<  endl;
\}


void shm_[set subsys]::GetObject([set subsys]_cache * pshm_[set subsys]) \{
       pshm_[set subsys] = ([set subsys]_cache *) m_shared_mem;
\}


shm_[set subsys]::shm_[set subsys]()
\{
       key_t key = 0x[calcshmid $subsys];
       size_t [set subsys]_shmsize = $TOPICPROPS(bytesize);
       bool bCreated = false;

       m_[set subsys]_shmid = shmget(key, [set subsys]_shmsize, 0666);

       if (-1 == m_[set subsys]_shmid) \{

           if (ENOENT != errno) \{
               cerr << __FILE__ <<  \":\" <<  __LINE__ <<  \" Critical error in shmget\"  << endl;
               return;
           \}

           m_[set subsys]_shmid = shmget(key, [set subsys]_shmsize, IPC_CREAT | 0666);

           if (-1 == m_[set subsys]_shmid) \{
               cerr <<  __FILE__ <<  \":\" <<  __LINE__ <<  \" Critical error in shmget\" << endl;
               return;
           \}

           cout <<   \"Created the shared memory\" <<  endl;
           bCreated = true;
       \}

       m_shared_mem = ([set subsys]_cache *) shmat(m_[set subsys]_shmid, NULL, 0);

       if (-1 == (size_t)shm_[set subsys]::m_shared_mem) \{
           cerr <<  __FILE__ <<  \":\" <<  __LINE__ <<  \" Critical error in shmat\" << endl;
           return;
       \}

       if (bCreated) \{
           // Construct objects on the shared memory
          data = ([set subsys]_cache *)m_shared_mem;
          data->syncO = 0;
       \}

       return;
\}
"
