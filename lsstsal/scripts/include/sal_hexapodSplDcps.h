#ifndef SAL_HEXAPODSPLTYPES_H
#define SAL_HEXAPODSPLTYPES_H

#include "ccpp_sal_hexapod.h"

#include <c_base.h>
#include <c_misc.h>
#include <c_sync.h>
#include <c_collection.h>
#include <c_field.h>

extern c_metaObject __sal_hexapod_hexapod__load (c_base base);

extern c_metaObject __hexapod_Actuators__load (c_base base);
extern const char * __hexapod_Actuators__keys (void);
extern const char * __hexapod_Actuators__name (void);
struct _hexapod_Actuators ;
extern  c_bool __hexapod_Actuators__copyIn(c_base base, struct hexapod::Actuators *from, struct _hexapod_Actuators *to);
extern  void __hexapod_Actuators__copyOut(void *_from, void *_to);
struct _hexapod_Actuators {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_float Calibrated[18];
    c_long Raw[18];
};

extern c_metaObject __hexapod_Application__load (c_base base);
extern const char * __hexapod_Application__keys (void);
extern const char * __hexapod_Application__name (void);
struct _hexapod_Application ;
extern  c_bool __hexapod_Application__copyIn(c_base base, struct hexapod::Application *from, struct _hexapod_Application *to);
extern  void __hexapod_Application__copyOut(void *_from, void *_to);
struct _hexapod_Application {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_float Demand[6];
    c_float Error[6];
    c_float Position[6];
};

extern c_metaObject __hexapod_Electrical__load (c_base base);
extern const char * __hexapod_Electrical__keys (void);
extern const char * __hexapod_Electrical__name (void);
struct _hexapod_Electrical ;
extern  c_bool __hexapod_Electrical__copyIn(c_base base, struct hexapod::Electrical *from, struct _hexapod_Electrical *to);
extern  void __hexapod_Electrical__copyOut(void *_from, void *_to);
struct _hexapod_Electrical {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long error[16];
    c_short status[16];
    c_long voltage[16];
};

extern c_metaObject __hexapod_LimitSensors__load (c_base base);
extern const char * __hexapod_LimitSensors__keys (void);
extern const char * __hexapod_LimitSensors__name (void);
struct _hexapod_LimitSensors ;
extern  c_bool __hexapod_LimitSensors__copyIn(c_base base, struct hexapod::LimitSensors *from, struct _hexapod_LimitSensors *to);
extern  void __hexapod_LimitSensors__copyOut(void *_from, void *_to);
struct _hexapod_LimitSensors {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_short liftoff[18];
    c_short llimit[18];
};

extern c_metaObject __hexapod_Metrology__load (c_base base);
extern const char * __hexapod_Metrology__keys (void);
extern const char * __hexapod_Metrology__name (void);
struct _hexapod_Metrology ;
extern  c_bool __hexapod_Metrology__copyIn(c_base base, struct hexapod::Metrology *from, struct _hexapod_Metrology *to);
extern  void __hexapod_Metrology__copyOut(void *_from, void *_to);
struct _hexapod_Metrology {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long distance[18];
    c_long error[18];
    c_short status[18];
};

extern c_metaObject __hexapod_TC__load (c_base base);
extern const char * __hexapod_TC__keys (void);
extern const char * __hexapod_TC__name (void);
struct _hexapod_TC ;
extern  c_bool __hexapod_TC__copyIn(c_base base, struct hexapod::TC *from, struct _hexapod_TC *to);
extern  void __hexapod_TC__copyOut(void *_from, void *_to);
struct _hexapod_TC {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_float error[16];
    c_short status[16];
    c_float setpoint[16];
    c_float temperature[16];
};

extern c_metaObject __hexapod_command_clearError__load (c_base base);
extern const char * __hexapod_command_clearError__keys (void);
extern const char * __hexapod_command_clearError__name (void);
struct _hexapod_command_clearError ;
extern  c_bool __hexapod_command_clearError__copyIn(c_base base, struct hexapod::command_clearError *from, struct _hexapod_command_clearError *to);
extern  void __hexapod_command_clearError__copyOut(void *_from, void *_to);
struct _hexapod_command_clearError {
    c_short hexapodID;
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

extern c_metaObject __hexapod_command_configureAcceleration__load (c_base base);
extern const char * __hexapod_command_configureAcceleration__keys (void);
extern const char * __hexapod_command_configureAcceleration__name (void);
struct _hexapod_command_configureAcceleration ;
extern  c_bool __hexapod_command_configureAcceleration__copyIn(c_base base, struct hexapod::command_configureAcceleration *from, struct _hexapod_command_configureAcceleration *to);
extern  void __hexapod_command_configureAcceleration__copyOut(void *_from, void *_to);
struct _hexapod_command_configureAcceleration {
    c_short hexapodID;
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
    c_float accmax;
};

extern c_metaObject __hexapod_command_configureAzimuthCoeffsLut__load (c_base base);
extern const char * __hexapod_command_configureAzimuthCoeffsLut__keys (void);
extern const char * __hexapod_command_configureAzimuthCoeffsLut__name (void);
struct _hexapod_command_configureAzimuthCoeffsLut ;
extern  c_bool __hexapod_command_configureAzimuthCoeffsLut__copyIn(c_base base, struct hexapod::command_configureAzimuthCoeffsLut *from, struct _hexapod_command_configureAzimuthCoeffsLut *to);
extern  void __hexapod_command_configureAzimuthCoeffsLut__copyOut(void *_from, void *_to);
struct _hexapod_command_configureAzimuthCoeffsLut {
    c_short hexapodID;
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
    c_long headingInfo[6];
    c_float c1[6];
    c_float c2[6];
    c_float c3[6];
    c_float c4[6];
    c_float c5[6];
    c_float c6[6];
};

extern c_metaObject __hexapod_command_configureAzimuthRawLut__load (c_base base);
extern const char * __hexapod_command_configureAzimuthRawLut__keys (void);
extern const char * __hexapod_command_configureAzimuthRawLut__name (void);
struct _hexapod_command_configureAzimuthRawLut ;
extern  c_bool __hexapod_command_configureAzimuthRawLut__copyIn(c_base base, struct hexapod::command_configureAzimuthRawLut *from, struct _hexapod_command_configureAzimuthRawLut *to);
extern  void __hexapod_command_configureAzimuthRawLut__copyOut(void *_from, void *_to);
struct _hexapod_command_configureAzimuthRawLut {
    c_short hexapodID;
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
    c_long headingInfo[35];
    c_float fz1[35];
    c_float fz2[35];
    c_float fz3[35];
    c_float fz4[35];
    c_float fz5[35];
    c_float fz6[35];
};

extern c_metaObject __hexapod_command_configureElevationCoeffsLut__load (c_base base);
extern const char * __hexapod_command_configureElevationCoeffsLut__keys (void);
extern const char * __hexapod_command_configureElevationCoeffsLut__name (void);
struct _hexapod_command_configureElevationCoeffsLut ;
extern  c_bool __hexapod_command_configureElevationCoeffsLut__copyIn(c_base base, struct hexapod::command_configureElevationCoeffsLut *from, struct _hexapod_command_configureElevationCoeffsLut *to);
extern  void __hexapod_command_configureElevationCoeffsLut__copyOut(void *_from, void *_to);
struct _hexapod_command_configureElevationCoeffsLut {
    c_short hexapodID;
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
    c_long headingInfo[6];
    c_float c1[6];
    c_float c2[6];
    c_float c3[6];
    c_float c4[6];
    c_float c5[6];
    c_float c6[6];
};

extern c_metaObject __hexapod_command_configureElevationRawLut__load (c_base base);
extern const char * __hexapod_command_configureElevationRawLut__keys (void);
extern const char * __hexapod_command_configureElevationRawLut__name (void);
struct _hexapod_command_configureElevationRawLut ;
extern  c_bool __hexapod_command_configureElevationRawLut__copyIn(c_base base, struct hexapod::command_configureElevationRawLut *from, struct _hexapod_command_configureElevationRawLut *to);
extern  void __hexapod_command_configureElevationRawLut__copyOut(void *_from, void *_to);
struct _hexapod_command_configureElevationRawLut {
    c_short hexapodID;
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
    c_long headingInfo[19];
    c_float fz1[19];
    c_float fz2[19];
    c_float fz3[19];
    c_float fz4[19];
    c_float fz5[19];
    c_float fz6[19];
};

extern c_metaObject __hexapod_command_configureLimits__load (c_base base);
extern const char * __hexapod_command_configureLimits__keys (void);
extern const char * __hexapod_command_configureLimits__name (void);
struct _hexapod_command_configureLimits ;
extern  c_bool __hexapod_command_configureLimits__copyIn(c_base base, struct hexapod::command_configureLimits *from, struct _hexapod_command_configureLimits *to);
extern  void __hexapod_command_configureLimits__copyOut(void *_from, void *_to);
struct _hexapod_command_configureLimits {
    c_short hexapodID;
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
    c_float xmin;
    c_float xmax;
    c_float ymin;
    c_float ymax;
    c_float zmin;
    c_float zmax;
    c_float umin;
    c_float umax;
    c_float vmin;
    c_float vmax;
    c_float wmin;
    c_float wmax;
};

extern c_metaObject __hexapod_command_configureTemperatureCoeffsLut__load (c_base base);
extern const char * __hexapod_command_configureTemperatureCoeffsLut__keys (void);
extern const char * __hexapod_command_configureTemperatureCoeffsLut__name (void);
struct _hexapod_command_configureTemperatureCoeffsLut ;
extern  c_bool __hexapod_command_configureTemperatureCoeffsLut__copyIn(c_base base, struct hexapod::command_configureTemperatureCoeffsLut *from, struct _hexapod_command_configureTemperatureCoeffsLut *to);
extern  void __hexapod_command_configureTemperatureCoeffsLut__copyOut(void *_from, void *_to);
struct _hexapod_command_configureTemperatureCoeffsLut {
    c_short hexapodID;
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
    c_long headingInfo[6];
    c_float c1[6];
    c_float c2[6];
    c_float c3[6];
    c_float c4[6];
    c_float c5[6];
    c_float c6[6];
};

extern c_metaObject __hexapod_command_configureVelocity__load (c_base base);
extern const char * __hexapod_command_configureVelocity__keys (void);
extern const char * __hexapod_command_configureVelocity__name (void);
struct _hexapod_command_configureVelocity ;
extern  c_bool __hexapod_command_configureVelocity__copyIn(c_base base, struct hexapod::command_configureVelocity *from, struct _hexapod_command_configureVelocity *to);
extern  void __hexapod_command_configureVelocity__copyOut(void *_from, void *_to);
struct _hexapod_command_configureVelocity {
    c_short hexapodID;
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
    c_float xymax;
    c_float rxrymax;
    c_float zmax;
    c_float rzmax;
};

extern c_metaObject __hexapod_command_move__load (c_base base);
extern const char * __hexapod_command_move__keys (void);
extern const char * __hexapod_command_move__name (void);
struct _hexapod_command_move ;
extern  c_bool __hexapod_command_move__copyIn(c_base base, struct hexapod::command_move *from, struct _hexapod_command_move *to);
extern  void __hexapod_command_move__copyOut(void *_from, void *_to);
struct _hexapod_command_move {
    c_short hexapodID;
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

extern c_metaObject __hexapod_command_offset__load (c_base base);
extern const char * __hexapod_command_offset__keys (void);
extern const char * __hexapod_command_offset__name (void);
struct _hexapod_command_offset ;
extern  c_bool __hexapod_command_offset__copyIn(c_base base, struct hexapod::command_offset *from, struct _hexapod_command_offset *to);
extern  void __hexapod_command_offset__copyOut(void *_from, void *_to);
struct _hexapod_command_offset {
    c_short hexapodID;
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
    c_float x;
    c_float y;
    c_float z;
    c_float u;
    c_float v;
    c_float w;
    c_bool sync;
};

extern c_metaObject __hexapod_command_pivot__load (c_base base);
extern const char * __hexapod_command_pivot__keys (void);
extern const char * __hexapod_command_pivot__name (void);
struct _hexapod_command_pivot ;
extern  c_bool __hexapod_command_pivot__copyIn(c_base base, struct hexapod::command_pivot *from, struct _hexapod_command_pivot *to);
extern  void __hexapod_command_pivot__copyOut(void *_from, void *_to);
struct _hexapod_command_pivot {
    c_short hexapodID;
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
    c_float x;
    c_float y;
    c_float z;
};

extern c_metaObject __hexapod_command_positionSet__load (c_base base);
extern const char * __hexapod_command_positionSet__keys (void);
extern const char * __hexapod_command_positionSet__name (void);
struct _hexapod_command_positionSet ;
extern  c_bool __hexapod_command_positionSet__copyIn(c_base base, struct hexapod::command_positionSet *from, struct _hexapod_command_positionSet *to);
extern  void __hexapod_command_positionSet__copyOut(void *_from, void *_to);
struct _hexapod_command_positionSet {
    c_short hexapodID;
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
    c_float x;
    c_float y;
    c_float z;
    c_float u;
    c_float v;
    c_float w;
    c_bool sync;
};

extern c_metaObject __hexapod_command_rawPositionSet__load (c_base base);
extern const char * __hexapod_command_rawPositionSet__keys (void);
extern const char * __hexapod_command_rawPositionSet__name (void);
struct _hexapod_command_rawPositionSet ;
extern  c_bool __hexapod_command_rawPositionSet__copyIn(c_base base, struct hexapod::command_rawPositionSet *from, struct _hexapod_command_rawPositionSet *to);
extern  void __hexapod_command_rawPositionSet__copyOut(void *_from, void *_to);
struct _hexapod_command_rawPositionSet {
    c_short hexapodID;
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
    c_long a1;
    c_long a2;
    c_long a3;
    c_long a4;
    c_long a5;
    c_long a6;
    c_bool sync;
};

extern c_metaObject __hexapod_command_test__load (c_base base);
extern const char * __hexapod_command_test__keys (void);
extern const char * __hexapod_command_test__name (void);
struct _hexapod_command_test ;
extern  c_bool __hexapod_command_test__copyIn(c_base base, struct hexapod::command_test *from, struct _hexapod_command_test *to);
extern  void __hexapod_command_test__copyOut(void *_from, void *_to);
struct _hexapod_command_test {
    c_short hexapodID;
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
    c_long ivalue1;
    c_long ivalue2;
};

extern c_metaObject __hexapod_logevent_TempError__load (c_base base);
extern const char * __hexapod_logevent_TempError__keys (void);
extern const char * __hexapod_logevent_TempError__name (void);
struct _hexapod_logevent_TempError ;
extern  c_bool __hexapod_logevent_TempError__copyIn(c_base base, struct hexapod::logevent_TempError *from, struct _hexapod_logevent_TempError *to);
extern  void __hexapod_logevent_TempError__copyOut(void *_from, void *_to);
struct _hexapod_logevent_TempError {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long severity;
    c_string axis;
    c_float temp;
    c_double timeStamp;
    c_long priority;
};

extern c_metaObject __hexapod_logevent_TrackLost__load (c_base base);
extern const char * __hexapod_logevent_TrackLost__keys (void);
extern const char * __hexapod_logevent_TrackLost__name (void);
struct _hexapod_logevent_TrackLost ;
extern  c_bool __hexapod_logevent_TrackLost__copyIn(c_base base, struct hexapod::logevent_TrackLost *from, struct _hexapod_logevent_TrackLost *to);
extern  void __hexapod_logevent_TrackLost__copyOut(void *_from, void *_to);
struct _hexapod_logevent_TrackLost {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long severity;
    c_double timeStamp;
    c_long priority;
};

extern c_metaObject __hexapod_logevent_Tracking__load (c_base base);
extern const char * __hexapod_logevent_Tracking__keys (void);
extern const char * __hexapod_logevent_Tracking__name (void);
struct _hexapod_logevent_Tracking ;
extern  c_bool __hexapod_logevent_Tracking__copyIn(c_base base, struct hexapod::logevent_Tracking *from, struct _hexapod_logevent_Tracking *to);
extern  void __hexapod_logevent_Tracking__copyOut(void *_from, void *_to);
struct _hexapod_logevent_Tracking {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long severity;
    c_double timeStamp;
    c_long priority;
};

extern c_metaObject __hexapod_logevent_deviceError__load (c_base base);
extern const char * __hexapod_logevent_deviceError__keys (void);
extern const char * __hexapod_logevent_deviceError__name (void);
struct _hexapod_logevent_deviceError ;
extern  c_bool __hexapod_logevent_deviceError__copyIn(c_base base, struct hexapod::logevent_deviceError *from, struct _hexapod_logevent_deviceError *to);
extern  void __hexapod_logevent_deviceError__copyOut(void *_from, void *_to);
struct _hexapod_logevent_deviceError {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string device;
    c_long severity;
    c_double timeStamp;
    c_string code;
    c_long priority;
};

extern c_metaObject __hexapod_logevent_inPosition__load (c_base base);
extern const char * __hexapod_logevent_inPosition__keys (void);
extern const char * __hexapod_logevent_inPosition__name (void);
struct _hexapod_logevent_inPosition ;
extern  c_bool __hexapod_logevent_inPosition__copyIn(c_base base, struct hexapod::logevent_inPosition *from, struct _hexapod_logevent_inPosition *to);
extern  void __hexapod_logevent_inPosition__copyOut(void *_from, void *_to);
struct _hexapod_logevent_inPosition {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double timeStamp;
    c_long priority;
};

extern c_metaObject __hexapod_logevent_interlock__load (c_base base);
extern const char * __hexapod_logevent_interlock__keys (void);
extern const char * __hexapod_logevent_interlock__name (void);
struct _hexapod_logevent_interlock ;
extern  c_bool __hexapod_logevent_interlock__copyIn(c_base base, struct hexapod::logevent_interlock *from, struct _hexapod_logevent_interlock *to);
extern  void __hexapod_logevent_interlock__copyOut(void *_from, void *_to);
struct _hexapod_logevent_interlock {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string detail;
    c_double timeStamp;
    c_long priority;
};

extern c_metaObject __hexapod_logevent_limit__load (c_base base);
extern const char * __hexapod_logevent_limit__keys (void);
extern const char * __hexapod_logevent_limit__name (void);
struct _hexapod_logevent_limit ;
extern  c_bool __hexapod_logevent_limit__copyIn(c_base base, struct hexapod::logevent_limit *from, struct _hexapod_logevent_limit *to);
extern  void __hexapod_logevent_limit__copyOut(void *_from, void *_to);
struct _hexapod_logevent_limit {
    c_short hexapodID;
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_string axis;
    c_string llimit;
    c_string type;
    c_double timeStamp;
    c_long priority;
};

extern c_metaObject __hexapod_command__load (c_base base);
extern const char * __hexapod_command__keys (void);
extern const char * __hexapod_command__name (void);
struct _hexapod_command ;
extern  c_bool __hexapod_command__copyIn(c_base base, struct hexapod::command *from, struct _hexapod_command *to);
extern  void __hexapod_command__copyOut(void *_from, void *_to);
struct _hexapod_command {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_long private_seqNum;
    c_short hexapodID;
    c_string device;
    c_string property;
    c_string action;
    c_string itemValue;
    c_string modifiers;
};

extern c_metaObject __hexapod_ackcmd__load (c_base base);
extern const char * __hexapod_ackcmd__keys (void);
extern const char * __hexapod_ackcmd__name (void);
struct _hexapod_ackcmd ;
extern  c_bool __hexapod_ackcmd__copyIn(c_base base, struct hexapod::ackcmd *from, struct _hexapod_ackcmd *to);
extern  void __hexapod_ackcmd__copyOut(void *_from, void *_to);
struct _hexapod_ackcmd {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_long private_seqNum;
    c_short hexapodID;
    c_long ack;
    c_long error;
    c_string result;
};

extern c_metaObject __hexapod_logevent__load (c_base base);
extern const char * __hexapod_logevent__keys (void);
extern const char * __hexapod_logevent__name (void);
struct _hexapod_logevent ;
extern  c_bool __hexapod_logevent__copyIn(c_base base, struct hexapod::logevent *from, struct _hexapod_logevent *to);
extern  void __hexapod_logevent__copyOut(void *_from, void *_to);
struct _hexapod_logevent {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_long private_seqNum;
    c_short hexapodID;
    c_string message;
};

#endif
