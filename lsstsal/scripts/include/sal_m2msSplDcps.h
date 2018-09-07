#ifndef SAL_M2MSSPLTYPES_H
#define SAL_M2MSSPLTYPES_H

#include "ccpp_sal_m2ms.h"

#include <c_base.h>
#include <c_misc.h>
#include <c_sync.h>
#include <c_collection.h>
#include <c_field.h>

extern c_metaObject __sal_m2ms_m2ms__load (c_base base);

extern c_metaObject __m2ms_ActuatorLimitSwitches__load (c_base base);
extern const char * __m2ms_ActuatorLimitSwitches__keys (void);
extern const char * __m2ms_ActuatorLimitSwitches__name (void);
struct _m2ms_ActuatorLimitSwitches ;
extern  c_bool __m2ms_ActuatorLimitSwitches__copyIn(c_base base, struct m2ms::ActuatorLimitSwitches *from, struct _m2ms_ActuatorLimitSwitches *to);
extern  void __m2ms_ActuatorLimitSwitches__copyOut(void *_from, void *_to);
struct _m2ms_ActuatorLimitSwitches {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_bool forward[72];
    c_bool reverse[72];
};

extern c_metaObject __m2ms_AxialActuatorAbsolutePositionSteps__load (c_base base);
extern const char * __m2ms_AxialActuatorAbsolutePositionSteps__keys (void);
extern const char * __m2ms_AxialActuatorAbsolutePositionSteps__name (void);
struct _m2ms_AxialActuatorAbsolutePositionSteps ;
extern  c_bool __m2ms_AxialActuatorAbsolutePositionSteps__copyIn(c_base base, struct m2ms::AxialActuatorAbsolutePositionSteps *from, struct _m2ms_AxialActuatorAbsolutePositionSteps *to);
extern  void __m2ms_AxialActuatorAbsolutePositionSteps__copyOut(void *_from, void *_to);
struct _m2ms_AxialActuatorAbsolutePositionSteps {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long axialAbsolutePositionSteps[72];
};

extern c_metaObject __m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured__load (c_base base);
extern const char * __m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured__keys (void);
extern const char * __m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured__name (void);
struct _m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured ;
extern  c_bool __m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured__copyIn(c_base base, struct m2ms::AxialActuatorPositionAbsoluteEncoderPositionMeasured *from, struct _m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured *to);
extern  void __m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured__copyOut(void *_from, void *_to);
struct _m2ms_AxialActuatorPositionAbsoluteEncoderPositionMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double axialEncoderPositionMeasured[72];
};

extern c_metaObject __m2ms_AxialForcesMeasured__load (c_base base);
extern const char * __m2ms_AxialForcesMeasured__keys (void);
extern const char * __m2ms_AxialForcesMeasured__name (void);
struct _m2ms_AxialForcesMeasured ;
extern  c_bool __m2ms_AxialForcesMeasured__copyIn(c_base base, struct m2ms::AxialForcesMeasured *from, struct _m2ms_AxialForcesMeasured *to);
extern  void __m2ms_AxialForcesMeasured__copyOut(void *_from, void *_to);
struct _m2ms_AxialForcesMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double axialForceMeasured[72];
};

extern c_metaObject __m2ms_MirrorPositionMeasured__load (c_base base);
extern const char * __m2ms_MirrorPositionMeasured__keys (void);
extern const char * __m2ms_MirrorPositionMeasured__name (void);
struct _m2ms_MirrorPositionMeasured ;
extern  c_bool __m2ms_MirrorPositionMeasured__copyIn(c_base base, struct m2ms::MirrorPositionMeasured *from, struct _m2ms_MirrorPositionMeasured *to);
extern  void __m2ms_MirrorPositionMeasured__copyOut(void *_from, void *_to);
struct _m2ms_MirrorPositionMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double xTilt;
    c_double yTilt;
    c_double piston;
    c_double xPosition;
    c_double yPosition;
    c_double theta_z_position;
};

extern c_metaObject __m2ms_PowerStatus__load (c_base base);
extern const char * __m2ms_PowerStatus__keys (void);
extern const char * __m2ms_PowerStatus__name (void);
struct _m2ms_PowerStatus ;
extern  c_bool __m2ms_PowerStatus__copyIn(c_base base, struct m2ms::PowerStatus *from, struct _m2ms_PowerStatus *to);
extern  void __m2ms_PowerStatus__copyOut(void *_from, void *_to);
struct _m2ms_PowerStatus {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double voltages[16];
    c_double currents[16];
    c_bool onOff[16];
    c_ulong states[16];
};

extern c_metaObject __m2ms_RawDisplacement__load (c_base base);
extern const char * __m2ms_RawDisplacement__keys (void);
extern const char * __m2ms_RawDisplacement__name (void);
struct _m2ms_RawDisplacement ;
extern  c_bool __m2ms_RawDisplacement__copyIn(c_base base, struct m2ms::RawDisplacement *from, struct _m2ms_RawDisplacement *to);
extern  void __m2ms_RawDisplacement__copyOut(void *_from, void *_to);
struct _m2ms_RawDisplacement {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double rawPosition[72];
};

extern c_metaObject __m2ms_RawTelemetry__load (c_base base);
extern const char * __m2ms_RawTelemetry__keys (void);
extern const char * __m2ms_RawTelemetry__name (void);
struct _m2ms_RawTelemetry ;
extern  c_bool __m2ms_RawTelemetry__copyIn(c_base base, struct m2ms::RawTelemetry *from, struct _m2ms_RawTelemetry *to);
extern  void __m2ms_RawTelemetry__copyOut(void *_from, void *_to);
struct _m2ms_RawTelemetry {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long dataPacket[720];
};

extern c_metaObject __m2ms_StepVectorUpdate__load (c_base base);
extern const char * __m2ms_StepVectorUpdate__keys (void);
extern const char * __m2ms_StepVectorUpdate__name (void);
struct _m2ms_StepVectorUpdate ;
extern  c_bool __m2ms_StepVectorUpdate__copyIn(c_base base, struct m2ms::StepVectorUpdate *from, struct _m2ms_StepVectorUpdate *to);
extern  void __m2ms_StepVectorUpdate__copyOut(void *_from, void *_to);
struct _m2ms_StepVectorUpdate {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long steps[72];
};

extern c_metaObject __m2ms_SystemStatus__load (c_base base);
extern const char * __m2ms_SystemStatus__keys (void);
extern const char * __m2ms_SystemStatus__name (void);
struct _m2ms_SystemStatus ;
extern  c_bool __m2ms_SystemStatus__copyIn(c_base base, struct m2ms::SystemStatus *from, struct _m2ms_SystemStatus *to);
extern  void __m2ms_SystemStatus__copyOut(void *_from, void *_to);
struct _m2ms_SystemStatus {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_ulong statusBits[72];
};

extern c_metaObject __m2ms_TangentActuatorAbsolutePositionSteps__load (c_base base);
extern const char * __m2ms_TangentActuatorAbsolutePositionSteps__keys (void);
extern const char * __m2ms_TangentActuatorAbsolutePositionSteps__name (void);
struct _m2ms_TangentActuatorAbsolutePositionSteps ;
extern  c_bool __m2ms_TangentActuatorAbsolutePositionSteps__copyIn(c_base base, struct m2ms::TangentActuatorAbsolutePositionSteps *from, struct _m2ms_TangentActuatorAbsolutePositionSteps *to);
extern  void __m2ms_TangentActuatorAbsolutePositionSteps__copyOut(void *_from, void *_to);
struct _m2ms_TangentActuatorAbsolutePositionSteps {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_long tangentLink_0deg_absolutePositionSteps;
    c_long tangentLink_60deg_absolutePositionSteps;
    c_long tangentLink_120deg_absolutePositionSteps;
    c_long tangentLink_180deg_absolutePositionSteps;
    c_long tangentLink_240deg_absolutePositionSteps;
    c_long tangentLink_300deg_absolutePositionSteps;
};

extern c_metaObject __m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured__load (c_base base);
extern const char * __m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured__keys (void);
extern const char * __m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured__name (void);
struct _m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured ;
extern  c_bool __m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured__copyIn(c_base base, struct m2ms::TangentActuatorPositionAbsoluteEncoderPositionMeasured *from, struct _m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured *to);
extern  void __m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured__copyOut(void *_from, void *_to);
struct _m2ms_TangentActuatorPositionAbsoluteEncoderPositionMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double tangentLink_0deg_absoluteEncoderPositionMeasured;
    c_double tangentLink_60deg_absoluteEncoderPositionMeasured;
    c_double tangentLink_120deg_absoluteEncoderPositionMeasured;
    c_double tangentLink_180deg_absoluteEncoderPositionMeasured;
    c_double tangentLink_240deg_absoluteEncoderPositionMeasured;
    c_double tangentLink_300deg_absoluteEncoderPositionMeasured;
};

extern c_metaObject __m2ms_TangentForcesMeasured__load (c_base base);
extern const char * __m2ms_TangentForcesMeasured__keys (void);
extern const char * __m2ms_TangentForcesMeasured__name (void);
struct _m2ms_TangentForcesMeasured ;
extern  c_bool __m2ms_TangentForcesMeasured__copyIn(c_base base, struct m2ms::TangentForcesMeasured *from, struct _m2ms_TangentForcesMeasured *to);
extern  void __m2ms_TangentForcesMeasured__copyOut(void *_from, void *_to);
struct _m2ms_TangentForcesMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double tangentLink_0deg_forceMeasured;
    c_double tangentLink_60deg_forceMeasured;
    c_double tangentLink_120deg_forceMeasured;
    c_double tangentLink_180deg_forceMeasured;
    c_double tangentLink_240deg_forceMeasured;
    c_double tangentLink_300deg_forceMeasured;
};

extern c_metaObject __m2ms_TargetForces__load (c_base base);
extern const char * __m2ms_TargetForces__keys (void);
extern const char * __m2ms_TargetForces__name (void);
struct _m2ms_TargetForces ;
extern  c_bool __m2ms_TargetForces__copyIn(c_base base, struct m2ms::TargetForces *from, struct _m2ms_TargetForces *to);
extern  void __m2ms_TargetForces__copyOut(void *_from, void *_to);
struct _m2ms_TargetForces {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double setPoint[72];
    c_double forceComponent[72];
};

extern c_metaObject __m2ms_TemperaturesMeasured__load (c_base base);
extern const char * __m2ms_TemperaturesMeasured__keys (void);
extern const char * __m2ms_TemperaturesMeasured__name (void);
struct _m2ms_TemperaturesMeasured ;
extern  c_bool __m2ms_TemperaturesMeasured__copyIn(c_base base, struct m2ms::TemperaturesMeasured *from, struct _m2ms_TemperaturesMeasured *to);
extern  void __m2ms_TemperaturesMeasured__copyOut(void *_from, void *_to);
struct _m2ms_TemperaturesMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double temps[72];
    c_double intakeTemperatures[4];
    c_double exhaustTemperatures[4];
};

extern c_metaObject __m2ms_ZenithAngleMeasured__load (c_base base);
extern const char * __m2ms_ZenithAngleMeasured__keys (void);
extern const char * __m2ms_ZenithAngleMeasured__name (void);
struct _m2ms_ZenithAngleMeasured ;
extern  c_bool __m2ms_ZenithAngleMeasured__copyIn(c_base base, struct m2ms::ZenithAngleMeasured *from, struct _m2ms_ZenithAngleMeasured *to);
extern  void __m2ms_ZenithAngleMeasured__copyOut(void *_from, void *_to);
struct _m2ms_ZenithAngleMeasured {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_double ZenithAngleMeasured;
};

extern c_metaObject __m2ms_command_ApplyBendingMode__load (c_base base);
extern const char * __m2ms_command_ApplyBendingMode__keys (void);
extern const char * __m2ms_command_ApplyBendingMode__name (void);
struct _m2ms_command_ApplyBendingMode ;
extern  c_bool __m2ms_command_ApplyBendingMode__copyIn(c_base base, struct m2ms::command_ApplyBendingMode *from, struct _m2ms_command_ApplyBendingMode *to);
extern  void __m2ms_command_ApplyBendingMode__copyOut(void *_from, void *_to);
struct _m2ms_command_ApplyBendingMode {
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
    c_short bendingModeNbr[32];
    c_double bendingModeValue[32];
};

extern c_metaObject __m2ms_command_ApplyForce__load (c_base base);
extern const char * __m2ms_command_ApplyForce__keys (void);
extern const char * __m2ms_command_ApplyForce__name (void);
struct _m2ms_command_ApplyForce ;
extern  c_bool __m2ms_command_ApplyForce__copyIn(c_base base, struct m2ms::command_ApplyForce *from, struct _m2ms_command_ApplyForce *to);
extern  void __m2ms_command_ApplyForce__copyOut(void *_from, void *_to);
struct _m2ms_command_ApplyForce {
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
    c_double forceSetPoint[72];
};

extern c_metaObject __m2ms_command_MoveAxialActuator__load (c_base base);
extern const char * __m2ms_command_MoveAxialActuator__keys (void);
extern const char * __m2ms_command_MoveAxialActuator__name (void);
struct _m2ms_command_MoveAxialActuator ;
extern  c_bool __m2ms_command_MoveAxialActuator__copyIn(c_base base, struct m2ms::command_MoveAxialActuator *from, struct _m2ms_command_MoveAxialActuator *to);
extern  void __m2ms_command_MoveAxialActuator__copyOut(void *_from, void *_to);
struct _m2ms_command_MoveAxialActuator {
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
    c_short axialActuatorID;
    c_long relativeStepsToMove;
};

extern c_metaObject __m2ms_command_PositionMirror__load (c_base base);
extern const char * __m2ms_command_PositionMirror__keys (void);
extern const char * __m2ms_command_PositionMirror__name (void);
struct _m2ms_command_PositionMirror ;
extern  c_bool __m2ms_command_PositionMirror__copyIn(c_base base, struct m2ms::command_PositionMirror *from, struct _m2ms_command_PositionMirror *to);
extern  void __m2ms_command_PositionMirror__copyOut(void *_from, void *_to);
struct _m2ms_command_PositionMirror {
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
    c_double xTilt;
    c_double yTilt;
    c_double piston;
};

extern c_metaObject __m2ms_command_SetCorrectionMode__load (c_base base);
extern const char * __m2ms_command_SetCorrectionMode__keys (void);
extern const char * __m2ms_command_SetCorrectionMode__name (void);
struct _m2ms_command_SetCorrectionMode ;
extern  c_bool __m2ms_command_SetCorrectionMode__copyIn(c_base base, struct m2ms::command_SetCorrectionMode *from, struct _m2ms_command_SetCorrectionMode *to);
extern  void __m2ms_command_SetCorrectionMode__copyOut(void *_from, void *_to);
struct _m2ms_command_SetCorrectionMode {
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
    c_long Mode;
};

extern c_metaObject __m2ms_logevent_M2AssemblyInPosition__load (c_base base);
extern const char * __m2ms_logevent_M2AssemblyInPosition__keys (void);
extern const char * __m2ms_logevent_M2AssemblyInPosition__name (void);
struct _m2ms_logevent_M2AssemblyInPosition ;
extern  c_bool __m2ms_logevent_M2AssemblyInPosition__copyIn(c_base base, struct m2ms::logevent_M2AssemblyInPosition *from, struct _m2ms_logevent_M2AssemblyInPosition *to);
extern  void __m2ms_logevent_M2AssemblyInPosition__copyOut(void *_from, void *_to);
struct _m2ms_logevent_M2AssemblyInPosition {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_bool inPosition;
    c_long priority;
};

extern c_metaObject __m2ms_logevent_M2DetailedState__load (c_base base);
extern const char * __m2ms_logevent_M2DetailedState__keys (void);
extern const char * __m2ms_logevent_M2DetailedState__name (void);
struct _m2ms_logevent_M2DetailedState ;
extern  c_bool __m2ms_logevent_M2DetailedState__copyIn(c_base base, struct m2ms::logevent_M2DetailedState *from, struct _m2ms_logevent_M2DetailedState *to);
extern  void __m2ms_logevent_M2DetailedState__copyOut(void *_from, void *_to);
struct _m2ms_logevent_M2DetailedState {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_short state;
    c_long priority;
};

extern c_metaObject __m2ms_logevent_M2FaultState__load (c_base base);
extern const char * __m2ms_logevent_M2FaultState__keys (void);
extern const char * __m2ms_logevent_M2FaultState__name (void);
struct _m2ms_logevent_M2FaultState ;
extern  c_bool __m2ms_logevent_M2FaultState__copyIn(c_base base, struct m2ms::logevent_M2FaultState *from, struct _m2ms_logevent_M2FaultState *to);
extern  void __m2ms_logevent_M2FaultState__copyOut(void *_from, void *_to);
struct _m2ms_logevent_M2FaultState {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_short state;
    c_long priority;
};

extern c_metaObject __m2ms_logevent_M2SummaryState__load (c_base base);
extern const char * __m2ms_logevent_M2SummaryState__keys (void);
extern const char * __m2ms_logevent_M2SummaryState__name (void);
struct _m2ms_logevent_M2SummaryState ;
extern  c_bool __m2ms_logevent_M2SummaryState__copyIn(c_base base, struct m2ms::logevent_M2SummaryState *from, struct _m2ms_logevent_M2SummaryState *to);
extern  void __m2ms_logevent_M2SummaryState__copyOut(void *_from, void *_to);
struct _m2ms_logevent_M2SummaryState {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_seqNum;
    c_long private_origin;
    c_long private_host;
    c_short state;
    c_long priority;
};

extern c_metaObject __m2ms_command__load (c_base base);
extern const char * __m2ms_command__keys (void);
extern const char * __m2ms_command__name (void);
struct _m2ms_command ;
extern  c_bool __m2ms_command__copyIn(c_base base, struct m2ms::command *from, struct _m2ms_command *to);
extern  void __m2ms_command__copyOut(void *_from, void *_to);
struct _m2ms_command {
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

extern c_metaObject __m2ms_ackcmd__load (c_base base);
extern const char * __m2ms_ackcmd__keys (void);
extern const char * __m2ms_ackcmd__name (void);
struct _m2ms_ackcmd ;
extern  c_bool __m2ms_ackcmd__copyIn(c_base base, struct m2ms::ackcmd *from, struct _m2ms_ackcmd *to);
extern  void __m2ms_ackcmd__copyOut(void *_from, void *_to);
struct _m2ms_ackcmd {
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

extern c_metaObject __m2ms_logevent__load (c_base base);
extern const char * __m2ms_logevent__keys (void);
extern const char * __m2ms_logevent__name (void);
struct _m2ms_logevent ;
extern  c_bool __m2ms_logevent__copyIn(c_base base, struct m2ms::logevent *from, struct _m2ms_logevent *to);
extern  void __m2ms_logevent__copyOut(void *_from, void *_to);
struct _m2ms_logevent {
    c_string private_revCode;
    c_double private_sndStamp;
    c_double private_rcvStamp;
    c_long private_origin;
    c_long private_host;
    c_string message;
};

#endif
