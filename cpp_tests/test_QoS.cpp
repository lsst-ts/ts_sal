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

#include <catch2/catch_test_macros.hpp>

#include <SAL_Test.h>

#include <cstdlib>
#include <memory>
#include <sys/stat.h>

#define DATA_DIR "../tests/data"

TEST_CASE("No QoS") {
    REQUIRE(unsetenv("LSST_DDS_QOS") == 0);
    REQUIRE_THROWS(std::make_shared<SAL_Test>());
}

TEST_CASE("No QoS file") {
    REQUIRE(setenv("LSST_DDS_QOS", DATA_DIR "/not_a_file", 1) == 0);
    REQUIRE_THROWS(std::make_shared<SAL_Test>());
}

TEST_CASE("QoS missing profile") {
    const std::string profiles[] = {"AckcmdProfile", "CommandProfile", "EventProfile", "TelemetryProfile"};

    for (auto profile : profiles) {
	std::string filepath = DATA_DIR "/QoS_no_" + profile + ".xml";
	struct stat fileStat;
	REQUIRE(stat(filepath.c_str(), &fileStat) == 0);
	REQUIRE(setenv("LSST_DDS_QOS", ("file://" + filepath).c_str(), 1) == 0);
	REQUIRE_THROWS(std::make_shared<SAL_Test>());
    }
}
