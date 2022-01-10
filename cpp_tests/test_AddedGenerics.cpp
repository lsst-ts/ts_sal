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

#include <SAL_Script.h>
#include <SAL_Test.h>

#include <algorithm>

TEST_CASE("No CSC") {
    auto csc = std::make_shared<SAL_Script>();

    auto commands = csc->getCommandNames();
    auto events = csc->getEventNames();

    REQUIRE(std::find(commands.begin(), commands.end(), "enable") == commands.end());
    REQUIRE(std::find(events.begin(), events.end(), "summaryState") == events.end());

    REQUIRE_FALSE(std::find(commands.begin(), commands.end(), "configure") == commands.end());
    REQUIRE_FALSE(std::find(events.begin(), events.end(), "checkpoints") == events.end());
}

TEST_CASE("No EnterControl in generics CSC") {
    auto csc = std::make_shared<SAL_Test>();

    auto commands = csc->getCommandNames();
    auto events = csc->getEventNames();

    REQUIRE_FALSE(std::find(commands.begin(), commands.end(), "enable") == commands.end());
    REQUIRE_FALSE(std::find(events.begin(), events.end(), "summaryState") == events.end());

    REQUIRE(std::find(commands.begin(), commands.end(), "enterControl") == commands.end());
}
