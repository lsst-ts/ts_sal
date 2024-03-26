#include <iostream>
#include <sstream>
#include <string>
#include <cstdlib>
#include <cstring>
#include <signal.h>
#include <getopt.h>
#include <fstream>

#include "Test.hh"

#include <librdkafka/rdkafkacpp.h>

#include <avro/Encoder.hh>
#include <avro/Decoder.hh>
#include <avro/Generic.hh>
#include <avro/Specific.hh>
#include <avro/Exception.hh>
#include <avro/Compiler.hh>

class SALDeliveryReport : public RdKafka::DeliveryReportCb {
 public:
  void dr_cb (RdKafka::Message &msg) {
    switch (msg.err())
    {
      case RdKafka::ERR_NO_ERROR:
        std::cerr << "% Message produced (offset " << msg.offset() << ")" << std::endl;
        break;

      default:
        std::cerr << "% Message delivery failed: " << msg.errstr() << std::endl;
    }
  }
};

int
main()
{
   int partition=1;
   std::string errstr;
   std::string topic = "kakfaTest.lsst.sal.Test_ackcmd";

   RdKafka::Conf *kconf = RdKafka::Conf::create(RdKafka::Conf::CONF_GLOBAL);

   kconf->set("bootstrap.servers","sasquatch-tts-kafka-0.lsst.codes:9094", errstr);
   kconf->set("kafka.security.protocol","SASL_SSL", errstr);
   kconf->set("kafka.sasl.mechanism","SCRAM-SHA-512", errstr);
   kconf->set("kafka.sasl.username","ts-salkafka", errstr);
   kconf->set("kafka.sasl.password","Arpd8QY9B8NI", errstr);   
 
   SALDeliveryReport dr_cb;
   if (kconf->set("dr_cb", &dr_cb, errstr) != RdKafka::Conf::CONF_OK)
     FATAL(errstr);


   RdKafka::Producer *producer = RdKafka::Producer::create(kconf, errstr);
 
   std::unique_ptr<avro::OutputStream> out = avro::memoryOutputStream();
   avro::EncoderPtr topicEncoder avro::binaryEncoder();
   topicEncoder->init(*out);
   c::ackcmd SALInstance;
   SALInstance.salIndex=999;
   
   avro::encode(*topicEncoder, SALInstance);

   RdKafka::ErrorCode kerr = producer->produce(topic, partition,
                                                RdKafka::Producer::RK_MSG_COPY,
                                                out.data(), out.size(),
                                                NULL, 0, 0, NULL);

   if (kerr != RdKafka::ERR_NO_ERROR) {
      std::cerr << "% Failed to produce message: " << RdKafka::err2str(kerr) << std::endl;
   }

}

