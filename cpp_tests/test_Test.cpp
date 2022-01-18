/*
 * This file is part of TS SAL test suite.
 *
 * Developed for the LSST Telescope and Site Systems.
 * This product includes software developed by the LSST Project
 * (https://www.lsst.org).
 * See the COPYRIGHT file at the top-level directory of this distribution
 * for details of code ownership.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>

#include <SAL_Test.h>

#include <chrono>
#include <cmath>
#include <cstring>
#include <cstdlib>
#include <thread>

using namespace std::chrono_literals;
using namespace std::placeholders;

constexpr auto STD_SLEEP = 1ms;

template <class scalar>
void fillScalarsWithRandom(scalar *data) {
    data->boolean0 = random() > RAND_MAX / 2;
    data->byte0 = (random() & 0xFF) - 0x0F;
    data->short0 = (random() & 0xFFFF) - 0x0FFF;
    data->int0 = (random() & 0xFFFFFFFF) - 0x0FFFFFFF;
    data->long0 = random();
    data->longLong0 = random();
    data->unsignedShort0 = random() & 0xFFFF;
    data->unsignedInt0 = random() & 0xFFFFFFFF;
    data->unsignedLong0 = random();
    data->float0 = random() / 10000.0;
    data->double0 = random() / 10000.0;
    data->string0 = "Test";
}

template <class scalar>
void scalarsEqual(scalar *expected, scalar *measured) {
    REQUIRE(expected->boolean0 == measured->boolean0);
    REQUIRE(expected->byte0 == measured->byte0);
    REQUIRE(expected->short0 == measured->short0);
    REQUIRE(expected->int0 == measured->int0);
    REQUIRE(expected->long0 == measured->long0);
    REQUIRE(expected->longLong0 == measured->longLong0);
    REQUIRE(expected->unsignedShort0 == measured->unsignedShort0);
    REQUIRE(expected->float0 == measured->float0);
    REQUIRE(expected->double0 == measured->double0);
    REQUIRE(expected->string0 == measured->string0);
}

template <class array>
void fillArraysWithRandomValues(array *data) {
    for (int i = 0; i < 5; i++) {
	data->boolean0[i] = random() > RAND_MAX / 2;
	data->byte0[i] = (random() & 0xFF) - 0x0F;
	data->short0[i] = (random() & 0xFFFF) - 0x0FFF;
	data->int0[i] = (random() & 0xFFFFFFFF) - 0x0FFFFFFF;
	data->long0[i] = random();
	data->longLong0[i] = random();
	data->unsignedShort0[i] = random() & 0xFFFF;
	data->unsignedInt0[i] = random() & 0xFFFFFFFF;
	data->unsignedLong0[i] = random();
	data->float0[i] = random() / 10000.0;
	data->double0[i] = random() / 10000.0;
    }
}

template <class array>
void arraysEqual(array *expected, array *measured) {
    for (int i = 0; i < 5; i++) {
	REQUIRE(expected->boolean0[i] == measured->boolean0[i]);
	REQUIRE(expected->byte0[i] == measured->byte0[i]);
	REQUIRE(expected->short0[i] == measured->short0[i]);
	REQUIRE(expected->int0[i] == measured->int0[i]);
	REQUIRE(expected->long0[i] == measured->long0[i]);
	REQUIRE(expected->longLong0[i] == measured->longLong0[i]);
	REQUIRE(expected->unsignedShort0[i] == measured->unsignedShort0[i]);
	REQUIRE(expected->float0[i] == measured->float0[i]);
	REQUIRE(expected->double0[i] == measured->double0[i]);
    }
}

/**
 * Test that get newest after get oldest gets the newest value.
 * Uses the arrays topic. This tests DM-18491.
 */
template <class cls>
void getNewestAfterGetOldest(std::function<int(cls *)> putMethod, std::function<int(cls *)> getMethod,
			     std::function<int(cls *)> getSample, bool last = false) {
    constexpr int numLoops = 5;
    cls dataList[numLoops];
    cls data;

    for (int i = 0; i < numLoops; i++) {
	fillArraysWithRandomValues<cls>(&data);
	dataList[i] = data;
	REQUIRE(putMethod(&data) == SAL__OK);
    }

    // read and check the oldest value
    cls *expected_data = &(dataList[last ? numLoops - 1 : 0]);
    REQUIRE(getMethod(&data) == SAL__OK);
    arraysEqual<cls>(expected_data, &data);

    // read and check the newest value
    expected_data = &(dataList[numLoops - 1]);
    REQUIRE(getSample(&data) == (last ? SAL__NO_UPDATES : SAL__OK));
    arraysEqual<cls>(expected_data, &data);
}

/**
 * Check event late-joiner data, using the logevent_arrays topic.
 *
 * @param controller
 * @param remote
 * @param readFunc  function to read data, e.g. getEvent_arrays
 * @param readGetsOldest does the read function get the oldest data? Set true
 * for getNextSample and getEvent. Set false for getSample.
 */
void checkEvtLateJoinerData(std::shared_ptr<SAL_Test> controller, std::shared_ptr<SAL_Test> remote,
			    std::function<int(Test_logevent_arraysC *)> readFunc, bool readGetsOldest) {
    controller->salEventPub((char *)"Test_logevent_arrays");

    constexpr int nhist = 5;
    constexpr int nextra = 3;

    Test_logevent_arraysC dataList[nhist + nextra];

    // Write late-joiner samples (no subscriber yet)
    for (int i = 0; i < nhist; i++) {
	Test_logevent_arraysC data;
	fillArraysWithRandomValues<Test_logevent_arraysC>(&data);
	dataList[i] = data;
	REQUIRE(controller->logEvent_arrays(&data, 1) == SAL__OK);
    }

    remote->salEventSub((char *)"Test_logevent_arrays");

    if (readGetsOldest) {
	// Write new samples
	for (int i = 0; i < nextra; i++) {
	    Test_logevent_arraysC data;
	    fillArraysWithRandomValues<Test_logevent_arraysC>(&data);
	    dataList[nhist + i] = data;
	    REQUIRE(controller->logEvent_arrays(&data, 1) == SAL__OK);
	}

	// getEvent reads the oldest message first, so we should see all historical samples, followed by new
	// samples.
	for (auto expected_data : dataList) {
	    Test_logevent_arraysC data;
	    REQUIRE(readFunc(&data) == SAL__OK);
	    arraysEqual<Test_logevent_arraysC>(&expected_data, &data);
	}
    } else {
	Test_logevent_arraysC *expected_data = dataList + (nhist - 1);
	Test_logevent_arraysC data;
	REQUIRE(readFunc(&data) == SAL__OK);
	arraysEqual<Test_logevent_arraysC>(expected_data, &data);
    }

    Test_logevent_arraysC data;
    REQUIRE(readFunc(&data) == SAL__NO_UPDATES);
}

// number of loops for looped tests
constexpr int numLoops = 3;

constexpr int maxLoops = 5;

TEST_CASE("Test SAL") {
    auto remote = std::make_shared<SAL_Test>();
    auto controller = std::make_shared<SAL_Test>();

    SECTION("Leap second is >= 0") { REQUIRE(remote->getLeapSeconds() >= 0); }

    SECTION("Get current time") {
	int leapSeconds = 0;
	double measuredSeconds = 0.0;
	for (int i = 0; i < 2; i++) {
	    leapSeconds = remote->getLeapSeconds();
	    auto duration = chrono::system_clock::now().time_since_epoch();
	    measuredSeconds =
		    remote->getCurrentTime() -
		    (std::chrono::duration_cast<std::chrono::milliseconds>(duration).count()) / 1000.0;
	    if (fabs(leapSeconds - measuredSeconds) > 0.9) {
		// when measured on leap second transition, sleep a bit
		std::this_thread::sleep_for(2s);
		continue;
	    }
	    break;
	}

	REQUIRE(leapSeconds == Approx(measuredSeconds).margin(0.001));
    }

    SECTION("Get versions") {
	auto salVersion = remote->getSALVersion();
	REQUIRE(salVersion > "");

	auto xmlVersion = remote->getXMLVersion();
	REQUIRE(xmlVersion > "");
    }

    SECTION("Get oldest events") {
	remote->salEventSub((char *)"Test_logevent_scalars");
	controller->salEventPub((char *)"Test_logevent_scalars");

	Test_logevent_scalarsC dataArray[numLoops];
	for (int i = 0; i < numLoops; i++) {
	    Test_logevent_scalarsC data;
	    fillScalarsWithRandom<Test_logevent_scalarsC>(&data);
	    dataArray[i] = data;
	    REQUIRE(controller->logEvent_scalars(&data, 1) == SAL__OK);
	}

	for (auto expected_data : dataArray) {
	    Test_logevent_scalarsC data;
	    remote->getNextSample_logevent_scalars(&data);
	    scalarsEqual<Test_logevent_scalarsC>(&expected_data, &data);
	}

	// at this point there should be nothing on the queue
	Test_logevent_scalarsC data;
	REQUIRE(remote->getNextSample_logevent_scalars(&data) == SAL__NO_UPDATES);
    }

    SECTION("Get oldest telemetry",
	    "Write several telemetry messages and make sure gettting the oldest returns the data in the "
	    "expected order.") {
	remote->salTelemetrySub((char *)"Test_scalars");
	controller->salTelemetryPub((char *)"Test_scalars");

	Test_scalarsC dataArray[numLoops];
	for (int i = 0; i < numLoops; i++) {
	    Test_scalarsC data;
	    fillScalarsWithRandom<Test_scalarsC>(&data);
	    dataArray[i] = data;
	    REQUIRE(controller->putSample_scalars(&data) == SAL__OK);
	}

	for (auto expected_data : dataArray) {
	    Test_scalarsC data;
	    REQUIRE(remote->getNextSample_scalars(&data) == SAL__OK);
	    scalarsEqual<Test_scalarsC>(&expected_data, &data);
	}

	// at this point there should be nothing on the queue
	Test_scalarsC data;
	REQUIRE(remote->getNextSample_scalars(&data) == SAL__NO_UPDATES);
    }

    SECTION("Get newest events",
	    "Write several messages and make sure gettting the newest returns that and flushes the queue.") {
	remote->salEventSub((char *)"Test_logevent_arrays");
	controller->salEventPub((char *)"Test_logevent_arrays");

	Test_logevent_arraysC dataArray[numLoops];
	for (int i = 0; i < numLoops; i++) {
	    Test_logevent_arraysC data;
	    fillArraysWithRandomValues<Test_logevent_arraysC>(&data);
	    dataArray[i] = data;
	    REQUIRE(controller->logEvent_arrays(&data, 1) == SAL__OK);
	}

	Test_logevent_arraysC *expected_data = &(dataArray[numLoops - 1]);
	Test_logevent_arraysC data;
	REQUIRE(remote->getSample_logevent_arrays(&data) == SAL__OK);
	arraysEqual<Test_logevent_arraysC>(expected_data, &data);

	// at this point there should be nothing on the queue
	REQUIRE(remote->getNextSample_logevent_arrays(&data) == SAL__NO_UPDATES);
	REQUIRE(remote->getSample_logevent_arrays(&data) == SAL__NO_UPDATES);
    }

    SECTION("Get newest telemetry",
	    "Write several messages and make sure gettting the newest returns that and flushes the queue.") {
	remote->salTelemetrySub((char *)"Test_arrays");
	controller->salTelemetryPub((char *)"Test_arrays");

	Test_arraysC dataList[numLoops];
	for (int i = 0; i < numLoops; i++) {
	    Test_arraysC data;
	    fillArraysWithRandomValues<Test_arraysC>(&data);
	    dataList[i] = data;
	    REQUIRE(controller->putSample_arrays(&data) == SAL__OK);
	}

	Test_arraysC *expected_data = &(dataList[numLoops - 1]);
	Test_arraysC data;
	remote->getSample_arrays(&data);
	arraysEqual<Test_arraysC>(expected_data, &data);

	// at this point there should be nothing on the queue
	REQUIRE(remote->getNextSample_arrays(&data) == SAL__NO_UPDATES);
	REQUIRE(remote->getSample_arrays(&data) == SAL__NO_UPDATES);
    }

    SECTION("Get newest events after get oldest",
	    "Test that get newest after get oldest gets the newest value. This tests DM-18491.") {
	remote->salEventSub((char *)"Test_logevent_arrays");
	controller->salEventPub((char *)"Test_logevent_arrays");

	getNewestAfterGetOldest<Test_logevent_arraysC>(
		std::bind(&SAL_Test::logEvent_arrays, controller, _1, 1),
		std::bind(&SAL_Test::getNextSample_logevent_arrays, remote, _1),
		std::bind(&SAL_Test::getSample_logevent_arrays, remote, _1));
	getNewestAfterGetOldest<Test_logevent_arraysC>(
		std::bind(&SAL_Test::logEvent_arrays, controller, _1, 1),
		std::bind(&SAL_Test::getSample_logevent_arrays, remote, _1),
		std::bind(&SAL_Test::getSample_logevent_arrays, remote, _1), true);
    }

    SECTION("Get newest telemetry after getNextSample",
	    "Test that get newest after getNextSample gets the newest value. This tests DM-18491.") {
	remote->salTelemetrySub((char *)"Test_arrays");
	controller->salTelemetryPub((char *)"Test_arrays");

	getNewestAfterGetOldest<Test_arraysC>(std::bind(&SAL_Test::putSample_arrays, controller, _1),
					      std::bind(&SAL_Test::getNextSample_arrays, remote, _1),
					      std::bind(&SAL_Test::getSample_arrays, remote, _1));
    }

    SECTION("Late joiner getNextSample (oldest events)",
	    "Check event late-joiner data, using the logevent_arrays topic.") {
	controller->salEventPub((char *)"Test_logevent_arrays");

	Test_logevent_arraysC dataList[maxLoops];
	for (int i = 0; i < maxLoops; i++) {
	    Test_logevent_arraysC data;
	    fillArraysWithRandomValues<Test_logevent_arraysC>(&data);
	    dataList[i] = data;
	    REQUIRE(controller->logEvent_arrays(&data, 1) == SAL__OK);
	}

	Test_logevent_arraysC data;
	remote->salEventSub((char *)"Test_logevent_arrays");

	REQUIRE(remote->getNextSample_logevent_arrays(&data) == SAL__OK);
	arraysEqual<Test_logevent_arraysC>(&data, &(dataList[0]));
    }

    SECTION("Late joiner getNextSample (newest telemetry)",
	    "Test that a late joiner cannot see historical telemetry using getNextSample. Telemetry is "
	    "volatile so there should be no late joiner data.") {
	controller->salTelemetryPub((char *)"Test_arrays");

	for (int i = 0; i < maxLoops; i++) {
	    Test_arraysC data;
	    fillArraysWithRandomValues<Test_arraysC>(&data);
	    REQUIRE(controller->putSample_arrays(&data) == SAL__OK);
	}

	Test_arraysC data;
	remote->salTelemetrySub((char *)"Test_arrays");

	REQUIRE(remote->getNextSample_arrays(&data) == SAL__NO_UPDATES);
    }

    SECTION("Late joiner getEvent (newest events)",
	    "Test that a late joiner can see an event using getEvent.") {
	controller->salEventPub((char *)"Test_logevent_arrays");

	Test_logevent_arraysC dataList[maxLoops];
	for (int i = 0; i < maxLoops; i++) {
	    Test_logevent_arraysC data;
	    fillArraysWithRandomValues<Test_logevent_arraysC>(&data);
	    dataList[i] = data;
	    REQUIRE(controller->logEvent_arrays(&data, 1) == SAL__OK);
	}

	remote->salEventSub((char *)"Test_logevent_arrays");

	for (int i = 0; i < maxLoops; i++) {
	    Test_logevent_arraysC data;
	    REQUIRE(remote->getEvent_arrays(&data) == SAL__OK);
	    arraysEqual<Test_logevent_arraysC>(&(dataList[i]), &data);
	}
    }

    SECTION("Late joiner getSample (newest telemetry)",
	    "Test that a late joiner cannot see historical telemetry using getSample. Telemetry is volatile "
	    "so there should be no late joiner data.") {
	controller->salTelemetryPub((char *)"Test_arrays");

	for (int i = 0; i < maxLoops; i++) {
	    Test_arraysC data;
	    fillArraysWithRandomValues<Test_arraysC>(&data);
	    REQUIRE(controller->putSample_arrays(&data) == SAL__OK);
	}

	Test_arraysC data;
	remote->salTelemetrySub((char *)"Test_arrays");
	REQUIRE(remote->getSample_arrays(&data) == SAL__NO_UPDATES);
    }

    SECTION("Late joiner getEvent", "Test that a late joiner can read historical events using getEvent.") {
	checkEvtLateJoinerData(controller, remote, std::bind(&SAL_Test::getEvent_arrays, remote, _1), true);
    }

    SECTION("Late joiner getEvent",
	    "Test that a late joiner can read historical events using getNextSample.") {
	checkEvtLateJoinerData(controller, remote,
			       std::bind(&SAL_Test::getNextSample_logevent_arrays, remote, _1), true);
    }

    SECTION("Late joiner getSample", "Test that a late joiner can read historical events using getSample.") {
	checkEvtLateJoinerData(controller, remote,
			       std::bind(&SAL_Test::getSample_logevent_arrays, remote, _1), false);
    }

    SECTION("Enumerations") {
	// Shared enum with default values
	REQUIRE(Test::Test_shared_Enum_One == 1);
	REQUIRE(Test::Test_shared_Enum_Two == 2);
	REQUIRE(Test::Test_shared_Enum_Three == 3);
	// Shared enum with specified values
	REQUIRE(Test::Test_shared_ValueEnum_Zero == 0);
	REQUIRE(Test::Test_shared_ValueEnum_Two == 2);
	REQUIRE(Test::Test_shared_ValueEnum_Four == 4);
	REQUIRE(Test::Test_shared_ValueEnum_Five == 5);
	// Topic - specific enum with default values
	REQUIRE(Test::scalars_Int0Enum_One == 1);
	REQUIRE(Test::scalars_Int0Enum_Two == 2);
	REQUIRE(Test::scalars_Int0Enum_Three == 3);
	// Topic - specific enum with specified values
	REQUIRE(Test::arrays_Int0ValueEnum_Zero == 0);
	REQUIRE(Test::arrays_Int0ValueEnum_Two == 2);
	REQUIRE(Test::arrays_Int0ValueEnum_Four == 4);
	REQUIRE(Test::arrays_Int0ValueEnum_Five == 5);
    }

    remote->salShutdown();
    controller->salShutdown();
}
