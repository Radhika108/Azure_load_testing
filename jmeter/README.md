# Introduction
This repo is meant to house the performance testing scripts created for testing against Isometrix.
CUrrently this stage all the work is being done from the perspective of Anglo.
Apache JMeter is used.

# Getting Started
1.	Software requirements
    - Java (version 8 or higher)
    - Apache Jmeter (latest version - currently 5.3)
2.	Configuration
    - Windows
        - Preferable to have JAVA_HOME environment variable set as per https://jmeter.apache.org/usermanual/get-started.html
        - Refrain from using Windows path notation as issues have been experienced when attempting to do this. (File paths etc.).  Use Unix notation, the JVM will translate accordingly.

# Execution of tests
Only execute load tests in CLI (non-gui) mode.
Executing in the GUI uses a lot of resources that will impact performance.

JMeter runs in a JVM, for which arguments need to be passed regarding heap size.
This may be done by setting values in a file in the JMETER_HOME/bin directory.
For Mac/Linux, this file is setenv.sh
For Windows, this file is setenv.bat

The arguments may also be passed from the terminal as part of the execution commands, some examples are provided further down in this document but please, also refer to https://jmeter.apache.org for further detail.

## JMeter Properties for managing execution
The scripts have been set up in such a way that they may be executed by passing various JMeter properties from the terminal/command prompt/command line (dependant on your flavour of operating system).

These properties are all listed in the Test Plan (root) of the Jmeter script file.
There are many that are not currently being used but they'll be used again at a later stage, hence their continued presence.
These properties also have default values set, with most of them being "0" (zero), so if a value is not provided, it probably means something won't be done, with some exceptions.

The list of properties are as follows:
influxdbhost	${__P(influxdbhost,10.0.0.79)}
host	${__P(host,project-anglo.isometrix.net)}
extrapath	${__P(extrapath,)}
protocol	${__P(protocol,https)}
port	${__P(port,443)}
username	${__P(username,automatedUser)}
password	${__P(password,automatedUser)}
thinktime-random-delay	${__P(thinktime-random-delay,15000)}
thinktime-constant-offset	${__P(thinktime-constant-offset,5000)}
duration	${__P(duration,0)}
responsetime	${__P(responsetime,10000)}
rampup	${__P(rampup,0)}
delay	${__P(delay,0)}
loopcount_scenarios	${__P(loopcount_scenarios,${__Random(1,5,)})}
threads_manageisometrix	${__P(threads_manageisometrix,0)}
threads_transactional	${__P(threads_transactional,0)}
threads_sequential	${__P(threads_sequential,0)}
threads_inspectionsearch	${__P(threads_inspectionsearch,0)}
threads_inspections	${__P(threads_inspections,0)}
threads_engagements	${__P(threads_engagements,0)}
threads_baselinerisk	${__P(threads_baselinerisk,0)}
threads_auditmanagement	${__P(threads_auditmanagement,0)}
threads_eventmanagement	${__P(threads_eventmanagement,0)}

The most/currently used properties are towards the top, and those not currently used towards the bottom.
Most of them should hopefully be relatively self-explanatory.

These properties are passed to JMeter with the -J[prop_name]=[value].

Example of executing a JMeter test from CLI (headless mode) - also assuming JMETER_HOME and Path environment variables have been set...:
jmeter -n -t my_test.jmx -l log.jtl

To relate this with the script in this repo...it shall be something along the following lines...
(This also assumes the relevant environment variables have been set and that the starting directory is the root of this repo.)

Mac/Linux:
jmeter -Jthreads_manageisometrix=1 -Jthreads_transactional=19 -Jrampup=300 -Jduration=3600 -Jhost=project-anglo.isometrix.net -Jusername=automatedUser -Jpassword=automatedUser -q scripts-anglo/anglocustom.user.properties -n -t scripts-anglo/web-plan.jmx -l jmeterhtmlreport/logfiles/log20201221at0700.jtl -e -o jmeterhtmlreport/htmlreports/20201221at0700

Windows:
jmeter.bat -Jthreads_manageisometrix=1 -Jthreads_transactional=1 -Jrampup=1 -Jduration=300 -Jhost="project-anglo.isometrix.net" -Jusername=automatedUser -Jpassword=automatedUser -q .\scripts-anglo\anglocustom.user.properties -n -t scripts-anglo\web-plan.jmx -l jmeterhtmlreport\logfiles\log20201221at0200.jtl -e -o jmeterhtmlreport\htmlreports\20201221at0200

The above example shall execute the script "web-plan.jmx" on the designated host (project-anglo.isometrix.net), with 1 thread (user) for the management threadgroup and 19 threads (users) on the transactional threadgroup, with a rampup of 300 seconds (1 user every 15 seconds) up to the max of 20.
It shall then execute for a duration of 3600 seconds (1hour).
A logfile has also been specified, namely "log20201221at0700.jtl", which shall then at the end of the run be used to also immediately generate a Jmeter HTML report in the following location:
jmeterhtmlreport/htmlreports/20201221at0700, and all this while also applying custom user.properties file "anglocustom.user.properties".

This readme is very basic, hopefully it'll be updated more comprehensively by early 2021.

# Authors
Dawid de Jager - dawid.dejager@isometrix.com
