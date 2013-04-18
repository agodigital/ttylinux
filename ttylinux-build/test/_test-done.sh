#!/bin/bash


# *****************************************************************************
# Show the test results.
# *****************************************************************************

echo -n "${MY_TEST_NAME} " | tee -a ${MY_LOGFILE}
for ((i=(70-${#MY_TEST_NAME}) ; i > 0 ; i--)); do
	echo -n "." | tee -a ${MY_LOGFILE}
done
[[ ${MY_TEST_OK} -eq 1 ]] && echo " PASS" | tee -a ${MY_LOGFILE} || true
[[ ${MY_TEST_OK} -eq 0 ]] && echo " FAIL" | tee -a ${MY_LOGFILE} || true


# *****************************************************************************
# Show the test time and make some time stamps.
# *****************************************************************************

MY_DONE_STAMP=${SECONDS}
_mins=$(((${MY_DONE_STAMP}-${MY_INIT_STAMP})/60))
_secs=$(((${MY_DONE_STAMP}-${MY_INIT_STAMP})%60))

echo ""                                            >>${MY_LOGFILE}
echo "Test Time ${_mins} minutes ${_secs} seconds" >>${MY_LOGFILE}
echo ""                                            >>${MY_LOGFILE}

unset _mins
unset _secs

date '+DATE:  %a. %h %d, 20%y' >>${MY_LOGFILE}
date '+TIME:  %r'              >>${MY_LOGFILE}

