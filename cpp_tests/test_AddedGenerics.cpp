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

#include <SAL_Script.h>
#include <SAL_Test.h>

#include <algorithm>
#include <memory>
#include <string>
#include <vector>

bool hasattr(std::vector<std::string> list, const char *attr) {
    return std::find(list.begin(), list.end(), attr) != list.end();
}

TEST_CASE("Events and commands in no CSC (Script component)") {
    auto csc = std::make_shared<SAL_Script>();

    auto commands = csc->getCommandNames();
    auto events = csc->getEventNames();

    // Topics in the csc category, which Script does not use
    REQUIRE_FALSE(hasattr(commands, "enable"));
    REQUIRE_FALSE(hasattr(events, "summaryState"));

    // Mandatory topics
    REQUIRE(hasattr(events, "heartbeat"));
    REQUIRE(hasattr(events, "logMessage"));

    // Component-specific topics
    REQUIRE(hasattr(commands, "configure"));
    REQUIRE(hasattr(events, "checkpoints"));
}

TEST_CASE("Events, telemetry and commands generics CSC (Test component)") {
    auto csc = std::make_shared<SAL_Test>();

    auto telemetry = csc->getTelemetryNames();
    auto commands = csc->getCommandNames();
    auto events = csc->getEventNames();

    // The enterControl command is not in the csc category
    REQUIRE_FALSE(hasattr(commands, "enterControl"));

    // Topics in the csc category
    REQUIRE(hasattr(commands, "enable"));
    REQUIRE(hasattr(events, "summaryState"));

    // Mandatory topics
    REQUIRE(hasattr(events, "heartbeat"));
    REQUIRE(hasattr(events, "logMessage"));

    // Component-specific topics
    REQUIRE(hasattr(commands, "wait"));
    REQUIRE(hasattr(events, "scalars"));
    REQUIRE(hasattr(telemetry, "arrays"));
}
