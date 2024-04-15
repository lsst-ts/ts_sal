package org.lsst.sal;

import org.apache.avro.*;
import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.KafkaFuture;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;  
import java.time.Duration;  
import java.util.Arrays;  
import java.util.Collections;  
import java.util.Properties;  

/** The SAL_SALData object is instantiated with an array of salActor data structures.
  * Each salActor maintains the state information for a single Kafka topic in the SALData namespace.
  * This includes AVRO datatypes , as well as SAL CSC specific information
 */ 
public class salActor {
/// baseName holds the name of the SALData object
	public String baseName;
/// topicName holds the root name of the Kafka Topic
	public String topicName;
/// topicHandle holds the actual name of the Kafka Topic with an AVRO versioned hash appended 
	public String topicHandle;
/// topicType holds the type of the topic (logevent,command,ackcmd,telemetry)
        public String topicType;
/// partition holds the Kafka partition to which the topic is associated with
        public String partition;
/// topic holds a pointer to the internal Kafka Topic object
	public String topic;
/// topic2 holds a pointer to the internal Kafka Topic object
        public String topic2;
/// topic holds a pointer to the internal Kafka Topic object
	public String avroName;
/// topic2 holds a pointer to the internal Kafka Topic object
        public String avroName2;
/// publisher holds a pointer to the internal Kafka Publisher object
	public KafkaProducer publisher;
/// subscriber holds a pointer to the internal Kafka Subscriber object
	public KafkaConsumer subscriber;
	public Schema avroSchema;
/// typeName holds the Kafka type, in our case it is the same as the topicHandle
	public String typeName;
/// typeName2 holds the complementary type of the ackCmd when typeName is a command topic
/// a commander needs an ackCmd subscriber , and a processor needs an ackCmd publisher
	public String typeName2;
/// isActive is true when the Actor has been connected to Kafka
        public Boolean isActive;
/// isEventReader is true when the Actor is a managing a SAL event subscriber
        public Boolean isReader;
/// isWriter is true when the Actor is a Kafka writer
        public Boolean isWriter;
/// isEventReader is true when the Actor is a managing a SAL event subscriber
        public Boolean isEventReader;
/// isEventWriter is true when the Actor is a managing a SAL event publisher
        public Boolean isEventWriter;
/// isCommand is true when the Actor is a managing a SAL command processor
        public Boolean isProcessor;
/// isCommand is true when the Actor is a managing a SAL commander
       public Boolean isCommand;
/// historyDepth is the maximum size (in samples) of the Kafka message cache for the topic
        public int historyDepth;
/// historyIndex is the index of the Kafka message store for the topic
        public int historyIndex;
/// debugLevel is the numerical level of verbosity controlling the output of debug messages
        public int debugLevel;
/// maxSamples is used to control the maximum number of Kafka messages received by getSample/getNextSample methods
        public int maxSamples;
/// sndSeqNum holds the sequence number of the most recent Kafka message sent for this topic
        public int sndSeqNum;
/// cmdSeqNum holds the sequence number of the most recent Kafka command sent for this topic
        public long cmdSeqNum;
/// sndSeqNum holds the sequence number of the most recent Kafka message received for this topic
        public long rcvSeqNum;
/// rcvOrigin holds the private_origin from the last received message for this topic 
        public long rcvOrigin;
/// rcvIdentity holds the private_identity filled from the last Kafka message received for this topic
        public String rcvIdentity;
/// error is the error field for the most recent ackCmd message (commands)
        public long error;
/// ack is the ack field for the most recent ackCmd message (commands)
        public long ack;
/// activeorigin is the private_origin field of the most recent command
        public long activeorigin;
/// activeidentity is the private_identity field of the most recent command
        public String activeidentity;
/// activecmdid is the command sequence number of the most recent command
        public long activecmdid;
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
        this.historyDepth = 0;
        this.maxSamples = 0;
    }
}




