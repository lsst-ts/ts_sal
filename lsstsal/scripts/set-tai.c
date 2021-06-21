/**
 \file set-tai.c
 \brief Set tai offset in Linux kernel
 *
 *              by: John Stultz <john.stultz@linaro.org>
 *              (C) Copyright Linaro 2013
 *              Licensed under the GPLv2
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 */


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <sys/timex.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#ifdef KTEST
#include "../kselftest.h"
#else
static inline int ksft_exit_pass(void)
{
	exit(0);
}
static inline int ksft_exit_fail(void)
{
	exit(1);
}
#endif

int set_tai(int offset)
{
	struct timex tx;

	memset(&tx, 0, sizeof(tx));

	tx.modes = ADJ_TAI;
	tx.constant = offset;

	return adjtimex(&tx);
}

int get_tai(void)
{
	struct timex tx;

	memset(&tx, 0, sizeof(tx));

	adjtimex(&tx);
	return tx.tai;
}

int main(int argc, char **argv)
{
    int i, ret;

    ret = get_tai();
    printf("tai offset started at %i\n", ret);

    if (argc < 2)
    {
        printf("New offset not given, not setting\n");
    }
    else
    {
        i = strtol(argv[1],NULL,10);
        printf("Attempting to set TAI offset to %d\n",i);
        printf("Checking tai offsets can be properly set: ");
        ret = set_tai(i);
        ret = get_tai();
        if (ret != i) {
            printf("[FAILED] expected: %i got %i\n", i, ret);
            return EXIT_FAILURE;
        }
    }
    printf("[OK]\n");
    return EXIT_SUCCESS;
}

