##########################################################################
# Allow PV name prefixes and serial port to be set from the environment
< envPaths

# For deviocstats
epicsEnvSet("ENGINEER", "Alireza Panna")
epicsEnvSet("LOCATION", "B1D521D DT-SMLIN113")
epicsEnvSet("STARTUP","$(TOP)/iocBoot/$(IOC)")
epicsEnvSet("ST_CMD","st.cmd")

# For stream proto file
epicsEnvSet "STREAM_PROTOCOL_PATH" "$(TOP)/db"
epicsEnvSet "P" "$(P=VPFI:SRI:xray)"
epicsEnvSet "R" "$(R=)"
epicsEnvSet "TTY" "$(TTY=/dev/ttyUSB0)"
# epicsEnvSet "TTY" "$(TTY=COM4)"
epicsEnvSet "EPICS_IOC_LOG_INET" "192.168.1.102"
epicsEnvSet "EPICS_IOC_LOG_PORT" "7004"
############################################################################
# Increase size of buffer for error logging from default 1256
errlogInit(20000)
############################################################################
# Register all support components
cd $(TOP)
dbLoadDatabase "dbd/sri.dbd"
sri_registerRecordDeviceDriver pdbbase
############################################################################
# Set up ASYN ports
# drvAsynSerialPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynSerialPortConfigure("L0","$(TTY)",0,0,0)
asynSetOption("L0", -1, "baud", "9600")
asynSetOption("L0", -1, "bits", "8")
asynSetOption("L0", -1, "parity", "none")
asynSetOption("L0", -1, "stop", "1")
asynSetOption("L0", -1, "clocal", "Y")
asynSetOption("L0", -1, "crtscts", "Y")
asynOctetSetInputEos("L0", -1, "\r")
asynOctetSetOutputEos("L0", -1, "\r")
#asynSetTraceIOMask("L0",-1,0x2)
#asynSetTraceMask("L0",-1,0x9)
############################################################################
# Load save_restore.cmd
cd $(IPL_SUPPORT)
< save_restore.cmd
set_requestfile_path("$(TOP)", "sriApp/Db")
############################################################################
# Load record instances
cd $(TOP)
dbLoadRecords("db/devsri.db","P=$(P),PORT=L0,A=0")
dbLoadRecords("db/iocAdminSoft.db", "IOC=$(P)")
dbLoadRecords("db/countDownTimer.vdb","P=$(P):, N=1")
asSetFilename("$(IPL_SUPPORT)/security.acf")
############################################################################
# Start EPICS IOC
cd $(STARTUP)
iocInit
############################################################################
# Start up the autosave task and tell it what to do.
create_monitor_set("auto_positions.req", 5, "P=$(P):")
create_monitor_set("auto_settings.req", 30, "P=$(P):")

# Handle autosave 'commands' contained in loaded databases
# Searches through the EPICS database for info nodes named 'autosaveFields' 
# and 'autosaveFields_pass0' and write the PV names to the files 
# 'info_settings.req' and 'info_positions.req'
makeAutosaveFiles()
create_monitor_set("info_positions.req",5,"P=$(P):")
create_monitor_set("info_settings.req",30,"P=$(P):")
############################################################################
# Start EPICS IOC log server
iocLogInit()
setIocLogDisable(0)
############################################################################
# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("$(EPICS_IOC_LOG_INET):$(EPICS_IOC_LOG_PORT)",1)
caPutLogShow(2)
############################################################################
# write all the PV names to a local file
dbl > records.txt
############################################################################
# Start any sequence programs
seq(&sri, "X=$(P)")
seqShow "sri"
############################################################################
# print the time our boot was finished
date
############################################################################