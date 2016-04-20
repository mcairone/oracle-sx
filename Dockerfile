
FROM oraclelinux:7

# Maintainer
# ----------
MAINTAINER Mario Cairone <mario.cairone@gmail.com>

ENV NGIX_URL  http://<ngix url and port>/files/soa/files/sx

ENV _SCRATCH /tmp/scratch
ENV ORA_HOME /home/oracle
ENV JDK_HOME ${ORA_HOME}/jdk
ENV FMW_HOME ${ORA_HOME}/product/12.2.1/oep

#SAVE the name of the downloaded files in vars
ENV JDK_FILE jdk-8u77-linux-x64.tar.gz
ENV SX_ZIP  fmw_12.2.1.0.0_ose_Disk1_1of1.zip
ENV INSTALL_FILE install.file
ENV SILENT_FILE silent.xml

ENV SERVER_DIR ${ORA_HOME}/config/12.2.1/oep/domains/oep_domain/oep_server
ENV PATH $PATH:${SERVER_DIR}


RUN	yum install -y -q xorg-x11-apps xauth libXtst tar unzip && \
	groupadd -g 1000 oinstall && \
	useradd -u 1000 -g 1000 -m oracle && \
	mkdir -p ${ORA_HOME} && \
	mkdir -p ${_SCRATCH} && \
	chown -R oracle:oinstall ${_SCRATCH} && \
	chown -R oracle:oinstall ${ORA_HOME}
	
USER oracle

RUN curl -o  ${_SCRATCH}/${SX_ZIP} ${NGIX_URL}/${SX_ZIP} && \
	curl -o  ${_SCRATCH}/${INSTALL_FILE} ${NGIX_URL}/${INSTALL_FILE} && \
	curl -o  ${_SCRATCH}/${JDK_FILE} ${NGIX_URL}/${JDK_FILE} && \
	curl -o  ${_SCRATCH}/${SILENT_FILE} ${NGIX_URL}/${SILENT_FILE} && \
	mkdir -p ${JDK_HOME} ${FMW_HOME} && \
	echo "inventory_loc=${FMW_HOME}/oraInventory" > ${_SCRATCH}/oraInst.loc && \
	echo "inst_group=oinstall" >> ${_SCRATCH}/oraInst.loc && \
	tar xzf ${_SCRATCH}/jdk-8u77-linux-x64.tar.gz -C ${JDK_HOME} --strip-components=1 && \
	rm -rf ${_SCRATCH}/jdk-8u77-linux-x64.tar.gz && \
	unzip ${_SCRATCH}/fmw_12.2.1.0.0_ose_Disk1_1of1.zip -d ${_SCRATCH} && \	
	${JDK_HOME}/bin/java -jar ${_SCRATCH}/fmw_12.2.1.0.0_oep.jar \
	-novalidation -silent -responseFile ${_SCRATCH}/install.file \ 
	-invPtrLoc ${_SCRATCH}/oraInst.loc && \
	rm -rf ${_SCRATCH}/fmw_12.2.1.0.0_ose_Disk1_1of1.zip \
	${_SCRATCH}/fmw_12.2.1.0.0_oep.jar && \
	${FMW_HOME}/oep/common/bin/config.sh -mode=silent -silent_xml=${_SCRATCH}/silent.xml -log=${_SCRATCH}/create_domain.log && \
	rm -rf ${_SCRATCH}

# Expose OEP port
EXPOSE 9002


WORKDIR ${SERVER_DIR}

# Define default command to start bash. 
CMD ["startwlevs.sh"]
