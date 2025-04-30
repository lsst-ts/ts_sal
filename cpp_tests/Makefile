SHELL=bash
all: compile

.PHONY: FORCE compile run junit clean

TEST_SRCS := $(shell ls test_*.cpp 2>/dev/null)
BINARIES := $(patsubst %.cpp,%,$(TEST_SRCS))
DEPS := $(patsubst %.cpp,%.cpp.d,$(TEST_SRCS))
JUNIT_FILES := $(shell ls *.xml 2>/dev/null)

CPP := g++ -std=c++14 -Wall -fmessage-length=0 -g

CFLAGS := \
	-I/usr/local/include \
	-fpermissive -g -D_REENTRANT -Wall -Wno-switch -Wno-format \
	-I"." -I"$(CONDA_PREFIX)/include/boost" -I"$(CONDA_PREFIX)/include/avro" \
	-I"$(SAL_WORK_DIR)/include" -Wno-write-strings \
	-I"${CONDA_PREFIX}/include" -I"$(SAL_WORK_DIR)/Test/cpp/src" -I"$(SAL_WORK_DIR)/Script/cpp/src"

LIBS := -L/usr/local/lib64 -lCatch2Main -lCatch2 -L${SAL_WORK_DIR}/lib -lSAL_Test -lSAL_Script \
	-ldl -lrt -lpthread -L$(CONDA_PREFIX)/lib -L/usr/lib64/boost1.78 -lboost_filesystem -lboost_iostreams \
	-lboost_program_options -lboost_system $(CONDA_PREFIX)/lib/libserdes++.a \
	$(CONDA_PREFIX)/lib/libserdes.a -lcurl -ljansson \
	-lrdkafka++ -lrdkafka -lavrocpp -lavro -lsasl2

ifneq ($(MAKECMDGOALS),clean)
    -include $(DEPS)
endif

ifndef VERBOSE
  co := @
endif

compile: $(BINARIES)

run: compile
	@${foreach b,${BINARIES},echo '[RUN] ${b}'; ./${b};}

junit: compile
	@$(foreach b,$(BINARIES),echo '[JUT] ${b}'; ./${b} -r junit -o ${b}.xml;)

clean:
	@$(foreach df,$(BINARIES) $(DEPS) $(JUNIT_FILES),echo '[RM ] ${df}'; $(RM) ${df};)

%.cpp.o: %.cpp.d
	@echo '[CPP] $(patsubst %.d,%,$<)'
	${co}$(CPP) $(CFLAGS) -c -fmessage-length=0 -o $@ $(patsubst %.d,%,$<)

%.cpp.d: %.cpp
	@echo '[DPP] $<'
	${co}$(CPP) $(CFLAGS) -M $< -MF $@ -MT '$(patsubst %.cpp,%.o,$<) $@'

${BINARIES}: %: %.cpp.o
	@echo '[TPP] $<'
	${co}$(CPP) -o $@ $(LIBS_FLAGS) $(CFLAGS) $^ ${LIBS}
