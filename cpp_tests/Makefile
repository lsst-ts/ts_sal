SHELL=bash
all: compile

.PHONY: FORCE compile run junit clean

TEST_SRCS := $(shell ls test_*.cpp 2>/dev/null)
BINARIES := $(patsubst %.cpp,%,$(TEST_SRCS))
DEPS := $(patsubst %.cpp,%.cpp.d,$(TEST_SRCS))
JUNIT_FILES := $(shell ls *.xml 2>/dev/null)

CXX ?= g++ -std=c++14 -Wall -fmessage-length=0 -g

CFLAGS := \
	-I/usr/local/include \
	-fpermissive -g -D_REENTRANT -Wall -Wno-switch -Wno-format \
	-I"." -I"$(CONDA_PREFIX)/include/boost" -I"$(CONDA_PREFIX)/include/avro" \
	-I"$(SAL_WORK_DIR)/include" -Wno-write-strings \
	-I"${CONDA_PREFIX}/include" -I"$(SAL_WORK_DIR)/Test/cpp/src" -I"$(SAL_WORK_DIR)/Script/cpp/src"

SAL_LIB_PREFIX ?= $(if $(LSST_SAL_PREFIX),$(LSST_SAL_PREFIX),$(CONDA_PREFIX))

# libschemaregistry replaces libserdes. Because libschemaregistry is a static
# archive, its vcpkg-built transitive deps (abseil, cpr, curl, compression)
# must be linked explicitly. These archives reference each other's symbols, so
# --start-group/--end-group makes the linker re-scan them until all the
# cross-references resolve, regardless of order. LIBSCHEMAREGISTRY_VCPKG_LIB
# defaults to the SAL prefix.
LIBSCHEMAREGISTRY_VCPKG_LIB ?= $(SAL_LIB_PREFIX)/lib
LIBSCHEMAREGISTRY_LDLIBS = -Wl,--start-group $(SAL_LIB_PREFIX)/lib/libschemaregistry.a $(wildcard $(LIBSCHEMAREGISTRY_VCPKG_LIB)/libabsl_*.a) $(LIBSCHEMAREGISTRY_VCPKG_LIB)/libcpr.a $(LIBSCHEMAREGISTRY_VCPKG_LIB)/libcurl.a $(LIBSCHEMAREGISTRY_VCPKG_LIB)/libz.a $(LIBSCHEMAREGISTRY_VCPKG_LIB)/libbz2.a $(LIBSCHEMAREGISTRY_VCPKG_LIB)/liblzma.a $(LIBSCHEMAREGISTRY_VCPKG_LIB)/libzstd.a -Wl,--end-group

LIBS := -L/usr/local/lib64 -lCatch2Main -lCatch2 -L${SAL_WORK_DIR}/lib -lSAL_Test -lSAL_Script \
	-ldl -lrt -lpthread -L$(SAL_LIB_PREFIX)/lib -L/usr/lib64/boost1.78 -lboost_filesystem -lboost_iostreams \
	-lboost_program_options -lboost_regex -lboost_system -lsnappy $(LIBSCHEMAREGISTRY_LDLIBS) \
	-lrdkafka++ -lrdkafka -lavrocpp -lsasl2 -lssl -lcrypto -llz4

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
	${co}$(CXX) $(CFLAGS) -c -fmessage-length=0 -o $@ $(patsubst %.d,%,$<)

%.cpp.d: %.cpp
	@echo '[DPP] $<'
	${co}$(CXX) $(CFLAGS) -M $< -MF $@ -MT '$(patsubst %.cpp,%.o,$<) $@'

${BINARIES}: %: %.cpp.o
	@echo '[TPP] $<'
	${co}$(CXX) -o $@ $(LIBS_FLAGS) $(CFLAGS) $^ ${LIBS}
