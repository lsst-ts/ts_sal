## \file sal_defines_dict.py
# \brief This contains SAL return codes for python use
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code



SAL__RETCODE = {
    "CMD_ACK": 300,
    "CMD_INPROGRESS": 301,
    "CMD_STALLED": 302,
    "CMD_COMPLETE": 303,
    "CMD_NOPERM": -300,
    "CMD_NOACK": -301,
    "CMD_FAILED": -302,
    "CMD_ABORTED": -303,
    "CMD_TIMEOUT": -304,
    "OK": 0,
    "ERR": -1,
    "ERROR": -1,
    "ILLEGAL_REVCODE": -2,
    "TOO_MANY_HANDLES": -3,
    "NOT_DEFINED": -4,
    # Generic State machine states
    "STATE_DISABLED": 1,
    "STATE_ENABLED": 2,
    "STATE_FAULT": 3,
    "STATE_OFFLINE": 4,
    "STATE_STANDBY": 5,
    # Timeout return codes
    "TIMEOUT": -5,
    "SIGNAL_INTERRUPT": -6,
    # getSample timeout specifiers (+ve is a time in microseconds)
    "WAIT_FOR_NEXT_UPDATE": -10000,
    "WAIT_FOR_CHANGE": -10001,
    # telemetry stream update types
    "NO_UPDATES": -100,
    "WAITING_FOR_NEXT": 100,
    "GOT_UPDATE": 101,
    "SYNC_IN": 102,
    "SYNC_OUT": 103,
    "SYNC_SET": 104,
    "SYNC_CLEAR": 105,
    "SYNC_READ": 106,
    # generateAlert types
    "EVENT_INFO": 200,
    "EVENT_WARN": -200,
    "EVENT_ERROR": -201,
    "EVENT_ABORT": -202,
    # callback types for subscriptions
    "DATA_AVAIL": 400,
    "DEADLINE_MISS": 401,
    "INCOMPAT_QOS": 402,
    "SAMPLE_REJ": 403,
    "LIVELINESS_CHG": 404,
    "SAMPLELOST": 405,
    "SUBSCR_MATCH": 406,
}

# DDS error codes
DDS__RETCODE = {
    "ERROR": 1,
    "UNSUPPORTED": 2,
    "BAD_PARAMETER": 3,
    "PRECONDITION_NOT_MET": 4,
    "OUT_OF_RESOURCES": 5,
    "NOT_ENABLED": 6,
    "IMMUTABLE_POLICY": 7,
    "INCONSISTENT_POLICY": 8,
    "ALREADY_DELETED": 9,
    "TIMEOUT": 10,
    "NO_DATA": 11,
    "ILLEGAL_OPERATION": 12,
    "HANDLE_EXPIRED": 13,
}
