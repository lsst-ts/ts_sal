#ifndef SAL_DOMESPLTYPES_H
#define SAL_DOMESPLTYPES_H

#include "ccpp_sal_dome.h"

#include <c_base.h>
#include <c_misc.h>
#include <c_sync.h>
#include <c_collection.h>
#include <c_field.h>

extern c_metaObject __sal_dome_dome__load (c_base base);

extern c_metaObject __dome_Summary__load (c_base base);
extern const char * __dome_Summary__keys (void);
extern const char * __dome_Summary__name (void);
struct _dome_Summary ;
extern  c_bool __dome_Summary__copyIn(c_base base, struct dome::Summary *from, struct _dome_Summary *to);
extern  void __dome_Summary__copyOut(void *_from, void *_to);
struct _dome_Summary {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_bool example[16];
};

extern c_metaObject __dome_command_CloseShutter__load (c_base base);
extern const char * __dome_command_CloseShutter__keys (void);
extern const char * __dome_command_CloseShutter__name (void);
struct _dome_command_CloseShutter ;
extern  c_bool __dome_command_CloseShutter__copyIn(c_base base, struct dome::command_CloseShutter *from, struct _dome_command_CloseShutter *to);
extern  void __dome_command_CloseShutter__copyOut(void *_from, void *_to);
struct _dome_command_CloseShutter {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_bool state;
};

extern c_metaObject __dome_command_Crawl__load (c_base base);
extern const char * __dome_command_Crawl__keys (void);
extern const char * __dome_command_Crawl__name (void);
struct _dome_command_Crawl ;
extern  c_bool __dome_command_Crawl__copyIn(c_base base, struct dome::command_Crawl *from, struct _dome_command_Crawl *to);
extern  void __dome_command_Crawl__copyOut(void *_from, void *_to);
struct _dome_command_Crawl {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_double azPosition;
    c_double elPosition;
    c_long demandTime;
};

extern c_metaObject __dome_command_Move__load (c_base base);
extern const char * __dome_command_Move__keys (void);
extern const char * __dome_command_Move__name (void);
struct _dome_command_Move ;
extern  c_bool __dome_command_Move__copyIn(c_base base, struct dome::command_Move *from, struct _dome_command_Move *to);
extern  void __dome_command_Move__copyOut(void *_from, void *_to);
struct _dome_command_Move {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_double azimuth;
    c_double elevation;
};

extern c_metaObject __dome_command_OpenShutter__load (c_base base);
extern const char * __dome_command_OpenShutter__keys (void);
extern const char * __dome_command_OpenShutter__name (void);
struct _dome_command_OpenShutter ;
extern  c_bool __dome_command_OpenShutter__copyIn(c_base base, struct dome::command_OpenShutter *from, struct _dome_command_OpenShutter *to);
extern  void __dome_command_OpenShutter__copyOut(void *_from, void *_to);
struct _dome_command_OpenShutter {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_bool state;
};

extern c_metaObject __dome_command_Park__load (c_base base);
extern const char * __dome_command_Park__keys (void);
extern const char * __dome_command_Park__name (void);
struct _dome_command_Park ;
extern  c_bool __dome_command_Park__copyIn(c_base base, struct dome::command_Park *from, struct _dome_command_Park *to);
extern  void __dome_command_Park__copyOut(void *_from, void *_to);
struct _dome_command_Park {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_bool state;
};

extern c_metaObject __dome_command_SetLouvers__load (c_base base);
extern const char * __dome_command_SetLouvers__keys (void);
extern const char * __dome_command_SetLouvers__name (void);
struct _dome_command_SetLouvers ;
extern  c_bool __dome_command_SetLouvers__copyIn(c_base base, struct dome::command_SetLouvers *from, struct _dome_command_SetLouvers *to);
extern  void __dome_command_SetLouvers__copyOut(void *_from, void *_to);
struct _dome_command_SetLouvers {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_long position[34];
};

extern c_metaObject __dome_command_StopShutter__load (c_base base);
extern const char * __dome_command_StopShutter__keys (void);
extern const char * __dome_command_StopShutter__name (void);
struct _dome_command_StopShutter ;
extern  c_bool __dome_command_StopShutter__copyIn(c_base base, struct dome::command_StopShutter *from, struct _dome_command_StopShutter *to);
extern  void __dome_command_StopShutter__copyOut(void *_from, void *_to);
struct _dome_command_StopShutter {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_bool state;
};

extern c_metaObject __dome_logevent_StateChanged__load (c_base base);
extern const char * __dome_logevent_StateChanged__keys (void);
extern const char * __dome_logevent_StateChanged__name (void);
struct _dome_logevent_StateChanged ;
extern  c_bool __dome_logevent_StateChanged__copyIn(c_base base, struct dome::logevent_StateChanged *from, struct _dome_logevent_StateChanged *to);
extern  void __dome_logevent_StateChanged__copyOut(void *_from, void *_to);
struct _dome_logevent_StateChanged {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long newState;
    c_long priority;
};

extern c_metaObject __dome_command__load (c_base base);
extern const char * __dome_command__keys (void);
extern const char * __dome_command__name (void);
struct _dome_command ;
extern  c_bool __dome_command__copyIn(c_base base, struct dome::command *from, struct _dome_command *to);
extern  void __dome_command__copyOut(void *_from, void *_to);
struct _dome_command {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_long private_seqNum;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_string modifiers;
};

extern c_metaObject __dome_ackcmd__load (c_base base);
extern const char * __dome_ackcmd__keys (void);
extern const char * __dome_ackcmd__name (void);
struct _dome_ackcmd ;
extern  c_bool __dome_ackcmd__copyIn(c_base base, struct dome::ackcmd *from, struct _dome_ackcmd *to);
extern  void __dome_ackcmd__copyOut(void *_from, void *_to);
struct _dome_ackcmd {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_long private_seqNum;
    c_long ack;
    c_long error;
    c_string result;
};

extern c_metaObject __dome_logevent__load (c_base base);
extern const char * __dome_logevent__keys (void);
extern const char * __dome_logevent__name (void);
struct _dome_logevent ;
extern  c_bool __dome_logevent__copyIn(c_base base, struct dome::logevent *from, struct _dome_logevent *to);
extern  void __dome_logevent__copyOut(void *_from, void *_to);
struct _dome_logevent {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_string message;
};

#endif
