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

// Depth of DDS read queues (which is also the depth of the write queues).
// This must be at least as long as the actual depth for some tests to pass.
// If it ever becomes possible to read or write the depth in SAL, update
// these tests to do that, to eliminate the dependence on the default depth.
constexpr int READ_QUEUE_DEPTH = 100;

// Add this to loop writing events - to make sure more than READ_QUEUE_DEPTH
// writes are made
constexpr int NEXTRA = 10;

TEST_CASE("Remote/controller") {
    auto remote = std::make_shared<SAL_Test>();
    auto controller = std::make_shared<SAL_Test>();

    SECTION("Invalid names") {
	REQUIRE_THROWS(controller->salProcessor((char*)"Test_command_nonexistent"));
	REQUIRE_THROWS(remote->salCommand((char*)"Test_command_nonexistent"));

	REQUIRE_THROWS(controller->salEventPub((char*)"Test_logevent_nonexistent"));
	REQUIRE_THROWS(remote->salEventSub((char*)"Test_logevent_nonexistent"));

	REQUIRE_THROWS(controller->salTelemetryPub((char*)"Test_nonexistent"));
	REQUIRE_THROWS(remote->salTelemetrySub((char*)"Test_nonexistent"));
    }

    SECTION("Unsubscribed command") {
	Test_command_setScalarsC data;

	REQUIRE_THROWS(controller->acceptCommand_setScalars(&data));
	REQUIRE_THROWS(remote->issueCommand_setScalars(&data));
    }

    SECTION("Unsubscribed event") {
	Test_logevent_scalarsC data;

	REQUIRE_THROWS(remote->getNextSample_logevent_scalars(&data));
	REQUIRE_THROWS(remote->getEvent_scalars(&data));
	REQUIRE_THROWS(remote->getSample_logevent_scalars(&data));
	REQUIRE_THROWS(remote->flushSamples_logevent_scalars(&data));

	REQUIRE_THROWS(controller->logEvent_scalars(&data, 0));
    }

    SECTION("Unsubscribed telemetry") {
	Test_scalarsC data;

	REQUIRE_THROWS(remote->getNextSample_scalars(&data));
	REQUIRE_THROWS(remote->getSample_scalars(&data));
	REQUIRE_THROWS(remote->flushSamples_scalars(&data));

	REQUIRE_THROWS(controller->putSample_scalars(&data));
    }

    SECTION("Overflow event buffer") {
	remote->salEventSub((char*)"Test_logevent_scalars");
	controller->salEventPub((char*)"Test_logevent_scalars");

	Test_logevent_scalarsC data;
	for (int val = 0; val < READ_QUEUE_DEPTH + NEXTRA; val++) {
	    data.int0 = val;
	    REQUIRE(controller->logEvent_scalars(&data, 1) == SAL__OK);
	}

	// make sure the queue overflowed
	REQUIRE(remote->getNextSample_logevent_scalars(&data) == SAL__OK);
	REQUIRE(data.int0 != 0);

	int start_value = data.int0;
	for (int i = 1; i < READ_QUEUE_DEPTH - 1; i++) {
	    REQUIRE(remote->getNextSample_logevent_scalars(&data) == SAL__OK);
	    REQUIRE(data.int0 == start_value + i);
	}
    }

    SECTION("Overflow telemetry buffer") {
	remote->salTelemetrySub((char*)"Test_scalars");
	controller->salTelemetryPub((char*)"Test_scalars");

	Test_scalarsC data;
	for (int val = 0; val < READ_QUEUE_DEPTH + NEXTRA; val++) {
	    data.int0 = val;
	    REQUIRE(controller->putSample_scalars(&data) == SAL__OK);
	}

	// make sure the queue overflowed
	REQUIRE(remote->getNextSample_scalars(&data) == SAL__OK);
	REQUIRE(data.int0 != 0);

	int start_value = data.int0;
	for (int i = 1; i < READ_QUEUE_DEPTH - 1; i++) {
	    REQUIRE(remote->getNextSample_scalars(&data) == SAL__OK);
	    REQUIRE(data.int0 == start_value + i);
	}
    }

    remote->salShutdown();
    controller->salShutdown();
}
