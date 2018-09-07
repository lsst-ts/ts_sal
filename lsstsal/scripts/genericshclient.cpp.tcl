set SHC(genericshclient.cpp) "

#include <iostream>
#include <stdlib.h>
using namespace std;

#include \"shmem_[set subsys].h\"

int main (int argc, char ** argv[])
\{
       [set subsys]_cache * pshm_[set subsys];
       shm_[set subsys] *obj = new shm_[set subsys]();

       obj->GetObject(pshm_[set subsys]);

       cout << (size_t)pshm_[set subsys] << \"\t\";

       cout << \"sync0 = \" << obj->syncO << endl;

       obj->Handle();

       return 0;
\}

#include <pthread.h>

void DoNothingCode() \{
       pthread_create(NULL, NULL, NULL, NULL);
\}

"
