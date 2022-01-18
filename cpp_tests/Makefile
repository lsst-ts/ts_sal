all: compile

.PHONY: FORCE compile run junit clean

TEST_SRCS := $(shell ls test_*.cpp 2>/dev/null)
BINARIES := $(patsubst %.cpp,%,$(TEST_SRCS))
DEPS := $(patsubst %.cpp,%.cpp.d,$(TEST_SRCS))
JUNIT_FILES := $(shell ls *.xml 2>/dev/null)

CPP := g++ -std=c++14 -Wall -fmessage-length=0 -g

CFLAGS := \
	-I${OSPL_HOME}/include                   \
	-I${OSPL_HOME}/include/sys               \
	-I${OSPL_HOME}/include/dcps/C++/SACPP    \
	-I${SAL_WORK_DIR}/include                \
	-I${SAL_HOME}/include                    \
	-I${CONDA_PREFIX}/include

LIBS := -L${SAL_WORK_DIR}/lib -lSAL_Test -lSAL_Script

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
