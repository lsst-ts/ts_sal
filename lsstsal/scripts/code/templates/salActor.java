package org.lsst.sal;

import org.opensplice.dds.dcps.TypeSupportImpl;
import DDS.*;
import DDS.DataReader;
import DDS.DataWriter;
import DDS.DataWriterQosHolder;
import DDS.DomainParticipant;
import DDS.DomainParticipantFactory;
import DDS.DurabilityQosPolicyKind;
import DDS.Publisher;
import DDS.PublisherQosHolder;
import DDS.ReliabilityQosPolicyKind;
import DDS.Subscriber;
import DDS.SubscriberQosHolder;
import DDS.Topic;
import DDS.TopicQosHolder;
import DDS.DurabilityQosPolicyKind;
import DDS.DataReader;
import DDS.SampleInfoSeqHolder;

/** The SAL_SALData object is instantiated with an array of salActor data structures.
  * Each salActor maintains the state information for a single DDS topic in the SALData namespace.
  * This includes DDS datatypes , as well as SAL CSC specific information
 */ 
public class salActor {
/// baseName holds the name of the SALData object
	public String baseName;
/// topicName holds the root name of the DDS topic
	public String topicName;
/// topicHandle holds the actual name of the DDS topic with an IDL versioned hash appended 
	public String topicHandle;
/// partition holds the DDS partition to which the topic is associated with
        public String partition;
/// topic holds a pointer to the internal DDS Topic object
	public Topic topic;
/// topic2 holds a pointer to the internal DDS Topic object
        public Topic topic2;
/// filteredtopic holds a pointer to the internal DDS topic for indexed DDS topics
        public ContentFilteredTopic filteredtopic;
/// filteredtopic2 holds a pointer to the internal DDS topic for indexed DDS topics
        public ContentFilteredTopic filteredtopic2;
/// topic_qos holds a pointer to the internal DDS TopicQos object
	public TopicQosHolder topicQos    = new TopicQosHolder();
/// topic_qos2 holds a pointer to the internal DDS TopicQos object
	public TopicQosHolder topicQos2   = new TopicQosHolder();
/// pub_qos holds a pointer to the internal DDS PublisherQos object
	public PublisherQosHolder pubQos  = new PublisherQosHolder();
/// sub_qos holds a pointer to the internal DDS SubscriberQos object
	public SubscriberQosHolder subQos = new SubscriberQosHolder();
/// dw_qos holds a pointer to the internal DDS DataWriterQos object
	public DataWriterQosHolder WQosH  = new DataWriterQosHolder();
/// dr_qos holds a pointer to the internal DDS DataReaderQos object
	public DataReaderQosHolder RQosH  = new DataReaderQosHolder();
/// publisher holds a pointer to the internal DDS Publisher object
	public Publisher publisher;
/// writer holds a pointer to the internal DDS DataReader object
	public DataWriter writer;
/// writer2 holds a pointer to the internal DDS DataWriter object
	public DataWriter writer2;
/// subscriber holds a pointer to the internal DDS Subscriber object
	public Subscriber subscriber;
/// reader holds a pointer to the internal DDS DataReader object
	public DataReader reader;
/// reader2 holds a pointer to the internal DDS DataReader object
	public DataReader reader2;
/// typeName holds the DDS type, in our case it is the same as the topicHandle
	public String typeName;
/// typeName2 holds the complementary type of the ackCmd when typeName is a command topic
/// a commander needs an ackCmd subscriber , and a processor needs an ackCmd publisher
	public String typeName2;
/// isActive is true when the Actor has been connected to DDS
        public Boolean isActive;
/// isEventReader is true when the Actor is a managing a SAL event subscriber
        public Boolean isReader;
/// isWriter is true when the Actor is a DDS writer
        public Boolean isWriter;
/// isEventReader is true when the Actor is a managing a SAL event subscriber
        public Boolean isEventReader;
/// isEventWriter is true when the Actor is a managing a SAL event publisher
        public Boolean isEventWriter;
/// isCommand is true when the Actor is a managing a SAL command processor
        public Boolean isProcessor;
/// isCommand is true when the Actor is a managing a SAL commander
       public Boolean isCommand;
/// historyDepth is the maximum size (in samples) of the DDS message cache for the topic
        public int historyDepth;
/// debugLevel is the numerical level of verbosity controlling the output of debug messages
        public int debugLevel;
/// maxSamples is used to control the maximum number of DDS messages received by getSample/getNextSample methods
        public int maxSamples;
/// sndSeqNum holds the sequence number of the most recent DDS message sent for this topic
        public int sndSeqNum;
/// cmdSeqNum holds the sequence number of the most recent DDS command sent for this topic
        public int cmdSeqNum;
/// sndSeqNum holds the sequence number of the most recent DDS message received for this topic
        public int rcvSeqNum;
/// rcvOrigin holds the private_origin from the last received message for this topic 
        public int rcvOrigin;
/// rcvIdentity holds the private_identity filled from the last DDS message received for this topic
        public String rcvIdentity;
/// error is the error field for the most recent ackCmd message (commands)
        public int error;
/// ack is the ack field for the most recent ackCmd message (commands)
        public int ack;
/// activehost is the private_identity field of the most recent command
        public int activehost;
/// activeorigin is the private_origin field of the most recent command
        public int activeorigin;
/// activeidentity is the private_identity field of the most recent command
        public String activeidentity;
/// activecmdid is the command sequence number of the most recent command
        public int activecmdid;
/// timeout is the number of seconds the command is expected to take to execute
        public double timeout;
/// result is the text message result of the most recent command
        public String result;
        public double timeRemaining;
/// sndStamp is the TAI timestamp of the most recent command sent
        public double sndStamp;
/// rcvStamp is the TAI timestamp of the most recent command received
        public double rcvStamp;
/// sampleAge is the time in seconds between command send and receive
	public double sampleAge;

/** The default salActor constructor initializes state of the booleans, history and max receive count 
 *
 */
    public salActor() {
	this.isActive = false;
	this.isReader = false;
	this.isWriter = false;
	this.isCommand = false;
	this.isEventReader = false;
	this.isEventWriter = false;
	this.isProcessor = false;
        this.historyDepth = 100;
        this.maxSamples = 999999999;
    }
}




