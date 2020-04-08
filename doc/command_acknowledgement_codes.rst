.. _lsst.ts.sal-acknowledgments:

############################
Command Acknowledgment Codes
############################

When programming with SAL it is important to use proper command acknowledgments codes. With consistent command acknowledgements codes project wide, we can reduce confusion and need for looking up acknowldgment definiton. *Client* in this document refers to the SAL component issuing the command, or the SAL Commander, or the salobj Remote. *Server* in this document refers to the SAL component being commanded, or the SAL Processor, or the salobj Controller.

There are two ways for the Client to ask the Server for a command acknowledgement using SAL. One is waitForCommandCompletion that accepts a timeout. The other is getResponse which will immediately ask for an acknowledgement and return CMD_NOACK if none is available.

Below are the list of acknowledgements you can use. In the context of DDS these values are the "ack" field of the "ackcmd" topic. To specifcy these in *ts_sal* use the code as the argument in the "ackCommand_x(ack)" function, where "x" is the command name. In ts_salobj ackcmd samples are usually created automatically, but one can create and return an ackcmd sample from a ControllerCommand callback function to override the automatically created sample.

**CMD_ACK = 300**
   Sent by the Server. The Server has accepted the command.

**CMD_INPROGRESS = 301**
   Sent by the Server. The Server has accepted the command and is processing the command.

**CMD_STALLED = 302**
   Sent by the Server. The Server has accepted the command and is expected to process for a *long* time. Useful when an application needs to cool down or warm up before it can continue. Can also send the average time expected to execute the command.

**CMD_COMPLETE = 303**
   Sent by the Server. The Server has completed the command. 

**CMD_NOPERM = -300**
   Sent by the whitelister. This Ack is returned to the Client when the Client tries to send a command to a Server it is not allowed to.

**CMD_NOACK = -301**
   Sent by SAL. This Ack is returned to the Client when the Client asks for an ack and there is nothing to send a response. This Ack is returned if there is no response from the commanded application.

**CMD_FAILED = -302**
   Sent by the Server. Can (hopefully) also send details on why the command has failed.
   
**CMD_ABORTED = -303**
   Sent by the Server. This ack is returned to the Client when the Server has aborted. 

**CMD_TIMEOUT = -304**
   Sent by the Server. This ack is returned to the Client when the Server has timed out. Useful when you have a lower level software that is not responsive and unable to perform the command.
 
CMD_ACK, CMD_INPROGRESS, CMD_NOACK and CMD_STALLED are not final: the caller can expect further acknowledgements for the command. All other codes are final, and all of those except CMD_COMPLETE indicates failure.

.. note:: in ts_salobj CMD_NOACK is only used in AckTimeoutError, the exception raised if the Client times out waiting for command acknowledgement from the Server.
