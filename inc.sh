function mytar() {
  tar "$*" | tee -a "$LOG" "$MAILLOG"
  ret="$PIPESTATUS[0]"
  if [[ "$ret" -ne 0 ]]; then
    handler TAR "$ret"
  fi
}

function mydd() {
  tar "$*" | tee -a "$LOG" "$MAILLOG"
  ret="$PIPESTATUS[0]"
  if [[ "$ret" -ne 0 ]]; then
    handler DD "$ret"
  fi
}

function mymt() {
  tar "$*" | tee -a "$LOG" "$MAILLOG"
  ret="$PIPESTATUS[0]"
  if [[ "$ret" -ne 0 ]]; then
    handler MT "$ret"
  fi
}

function readlabel() {
  local label
  label=$("$mydd" if="$TAPE_DEV" 2>/dev/null | head -1 | awk '{print $1}')
  ret=${PIPESTATUS[0]}
  if [[ "$ret" -ne 0 ]]; then handler DD 11; fi
  echo "Label is" "$label"   | tee -a "${LOG}" "${MAILLOG}"
  if [[ "$label" != "$LABEL_TAPE" ]] ; then
  handler "3"
else
  echo "Ok - label $LABEL_TAPE tape is correct" | tee -a "${LOG}" "${MAILLOG}"
fi

}


function maillog() {
  "$MAIL" -s "$1" "$ADMIN" < ${MAILLOG}
}

function handler() {
  case $1
  TAR)
   case $2
     *)
     ;;
   esac
   ;;
  MT)
   case $2
     *)
     ;;
   esac
   ;;
  DD)
   case $2
     *)
     ;;
   esac
   ;;
  EXIT)
   case $2
     *)
     ;;
   esac
   ;;
  *)
   ;;
  esac
}
