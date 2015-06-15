#!/bin/bash

# Error codes:
# 11 - cannot read label

# include envs and functions
. config
. inc.sh

# truncate mail and sms logs
if [[ -f "${MAILLOG}" ]]; then > "${MAILLOG}"; fi
if [[ -f "${SMSLOG}" ]]; then > "${SMSLOG}"; fi

date | tee -a "${LOG}" "${MAILLOG}" "${SMSLOG}"

echo "Rewinding tape" | tee -a "${LOG}" "${MAILLOG}"
"$mymt" -f "${TAPE_DEV}" rew 2>&1

echo 'Reading label' | tee -a "${LOG}" "${MAILLOG}"
"$readlabel"

echo 'Seeking last file on tape' | tee -a "${LOG}" "${MAILLOG}"
RET=0
"$mymt" -f $TAPE_DEV eom 2>&1 | tee -a "${LOG}" "${MAILLOG}"
RET=${PIPESTATUS[0]}
if [[ "$RET" -ne 0 ]]; then handler 5; fi

mt -f $TAPE_DEV nbsf 2>&1 | tee -a "${LOG}" "${MAILLOG}"
RET=${PIPESTATUS[0]}
if [[ "$RET" -ne 0 ]]; then handler 5; fi


echo "Last file on the ${LABEL_TAPE} tape is..." | tee -a "${LOG}" "${MAILLOG}"
tar tvbf 20000 "$TAPE_DEV"  | tee -a "${LOG}" "${MAILLOG}"

echo "Changing working dir to ${DIR_ARCH}" | tee -a "${LOG}" "${MAILLOG}"
cd "$DIR_ARCH"

# If no logs in DIR_ARCH, then successful exit
if [[ ! $(ls arch_*.arc 2>/dev/null) ]]; then 
  nofiles=1
  handler "0"
fi
  
echo "Processing archive logs to tape" | tee -a "${LOG}" "${MAILLOG}"

# Mail loop
for arch_file in arch_*.arc
do
  #echo "$arch_file" | tee -a "${LOG}" "${MAILLOG}"
  tar -cvbf 20000 "${TAPE_DEV}" "$arch_file" 2>&1 | tee -a "${LOG}" "${MAILLOG}"
  RET=${PIPESTATUS[0]}
  if [[ "$RET"  -ne 0 ]] ; then
    handler "$RET"
  else
    rm -f "$arch_file" 2>&1
    RMRET="$?"
    if [[ "$RMRET" -ne 0 ]]; then
      echo "Cannot delete $ARCH_FILE" | tee -a "${LOG}" "${MAILLOG}"
    fi 
  fi
done

handler "0"