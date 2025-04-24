FROM almalinux:9
# COPY . /opt/lsst/ts_sal/
RUN dnf install -y epel-release dnf-plugins-core && dnf config-manager -y --set-enabled crb
RUN dnf install -y ant cmake boost-devel jansson-devel asciidoc libcurl-devel zlib-devel maven doxygen fmt-devel snappy-devel csnappy gcc-toolset-13 cyrus-sasl-devel 
RUN curl -LO https://github.com/catchorg/Catch2/archive/refs/tags/v3.8.0.tar.gz && tar zxvf v3.8.0.tar.gz && cd Catch2-3.8.0 && source scl_source enable gcc-toolset-13 && cmake -Bbuild -H. -DBUILD_TESTING=OFF && cmake --build build/ --target install
# RUN git clone github.com/lsst-ts/ts_xml /opt/lsst/ts_xml
# WORKDIR /opt/lsst/ts_sal
# RUN source setupKakfa.env && source scl_enable gcc-toolset-13 && salgeneratorKafka validate Test Script && salgeneratorKafka sal cpp Test Script && salgeneratorKafka sal java Test Script && salgeneratorKafka lib Test Script && salgeneratorKafka maven Test Script
# RUN source ./setupKafka.env && source scl_source enable gcc-toolset-13 && cd cpp_tests && make junit

