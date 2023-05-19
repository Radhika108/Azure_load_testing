FROM justb4/jmeter:5.3

#WORKDIR /app
#COPY . .
#RUN ls


# https://jmeter-plugins.org/wiki/TestPlanCheckTool/
ENV PLAN_CHECK_PLUGIN_VERSION=2.4
RUN wget https://jmeter-plugins.org/files/packages/jpgc-plancheck-${PLAN_CHECK_PLUGIN_VERSION}.zip
RUN unzip -o jpgc-plancheck-${PLAN_CHECK_PLUGIN_VERSION}.zip -d ${JMETER_HOME}

#RUN wget https://jmeter-plugins.org/files/packages/jpgc-plancheck-${PLAN_CHECK_PLUGIN_VERSION}.zip
#RUN wget https://jmeter-plugins.org/files/packages/jpgc-casutg-2.9.zip
#RUN unzip -o jpgc-plancheck-${PLAN_CHECK_PLUGIN_VERSION}.zip -d ${JMETER_HOME}
#RUN unzip -o jpgc-casutg-2.9.zip -d ${JMETER_HOME}
#RUN wget https://jmeter-plugins.org/files/packages/jpgc-casutg-${CUSTOM_THREAD_VERSION}.zip
#RUN unzip -o jpgc-casutg-${CUSTOM_THREAD_VERSION}.zip -d ${JMETER_HOME}





EXPOSE 1099

ENTRYPOINT ["/entrypoint.sh"]