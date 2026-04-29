FROM almalinux:9
# COPY . /opt/lsst/ts_sal/
RUN dnf install -y epel-release dnf-plugins-core && dnf config-manager -y --set-enabled crb
RUN dnf install -y ant cmake boost-devel jansson-devel asciidoc libcurl-devel zlib-devel maven doxygen fmt-devel snappy-devel csnappy gcc-toolset-13 cyrus-sasl-devel
# libschemaregistry (OSW-2238) build prerequisites: ninja, pkgconfig, git,
# perl (vcpkg ports), java-11 (antlr/jsonata), tar/unzip/zip/curl (vcpkg).
RUN dnf install -y ninja-build pkgconfig git perl java-11-openjdk-devel tar unzip zip curl xz which
RUN curl -LO https://github.com/catchorg/Catch2/archive/refs/tags/v3.8.0.tar.gz && tar zxvf v3.8.0.tar.gz && cd Catch2-3.8.0 && source scl_source enable gcc-toolset-13 && cmake -Bbuild -H. -DBUILD_TESTING=OFF && cmake --build build/ --target install
# Bootstrap vcpkg used by libschemaregistry's CMake build (OSW-2238).
# The runtime build_libschemaregistry helper in bin/setup_functions.sh
# falls back to cloning vcpkg at first use if VCPKG_ROOT is missing, so
# this is a pre-warm to speed up container builds.
ENV VCPKG_ROOT=/opt/vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git /opt/vcpkg && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics
ENV PATH=/opt/vcpkg:${PATH}
# RUN git clone github.com/lsst-ts/ts_xml /opt/lsst/ts_xml
# WORKDIR /opt/lsst/ts_sal
# RUN source setupKakfa.env && source scl_enable gcc-toolset-13 && salgeneratorKafka validate Test Script && salgeneratorKafka sal cpp Test Script && salgeneratorKafka sal java Test Script && salgeneratorKafka lib Test Script && salgeneratorKafka maven Test Script
# RUN source ./setupKafka.env && source scl_source enable gcc-toolset-13 && cd cpp_tests && make junit

