# This does not need to be optional, because if make is here it has already found this directory. The call to _this_ file should be optional.
ifeq ($(shell uname), Linux)
include $(ms)/linux.mk
else
include $(ms)/unix.mk
endif

%.var:
	@echo $($*)

%.makevar:
	$(MAKE) $($*)
