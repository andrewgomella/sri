TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

#----------------------------------------------------
# Create and install (or just install) into <top>/db
# databases, templates, substitutions like this
#DB += xxx.db
ifdef AUTOSAVE
	$(PROD_IOC)_DBD += asSupport.dbd
	$(PROD_IOC)_LIBS += autosave
endif
ifdef DEVIOCSTATS
	DB_INSTALLS += $(DEVIOCSTATS)/db/iocAdminSoft.db
endif
ifdef STD
	DB_INSTALLS += $(STD)/stdApp/Db/timer.db
	DB_INSTALLS += $(STD)/stdApp/Db/timeString.db
	DB_INSTALLS += $(STD)/stdApp/Db/countDownTimer.vdb
	DB_INSTALLS += $(STD)/stdApp/Db/async_pid_control.db
endif
#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_template = <templatename>

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

