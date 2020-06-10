ARG base_image_tag

FROM lsstts/salobj:$base_image_tag

# Arguments for package versions
ARG sal_v="develop"
ARG xml_v="develop"

WORKDIR /home/saluser/repos/ts_sal
RUN /home/saluser/.checkout_repo.sh ${sal_v}

WORKDIR /home/saluser/repos/ts_xml
RUN /home/saluser/.checkout_repo.sh ${xml_v}

WORKDIR /home/saluser/repos/ts_sal
RUN source /home/saluser/.setup.sh && \
    setup ts_sal -t current && \
    scons --clean && scons
