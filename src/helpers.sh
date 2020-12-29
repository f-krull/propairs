pplog() {
  set -ETeuo pipefail
  local lvl
  lvl=$1
  readonly lvl
  local lvl_max
  lvl_max="$( [ ${CFG_VERBOSE} -eq 1 ] && echo 1 || echo 0 )"
  readonly lvl_max
  local logfn
  logfn="${OUTPUT_DIR}/log.txt"
  readonly logfn
  # print stuff to log
  IFS=$'\n'
  while read line; do
    echo $(date) $lvl "${line}" >> ${logfn}
    # check log-level and print to standard output if lower or equal
    if [ "$lvl" -le "$lvl_max" ]; then
      echo "${line}"
    fi
  done
  unset IFS
  return 0
}
export -f pplog

# read from stdin
function format_table() {
  set -ETeuo pipefail
  local -r num_cols=$1
  source ${PPROOT}/config/columns_def.sh
  header=( $(echo $TABLEHEADER) )
  {
    for i in ${!header[@]}; do
      [ $i -le $num_cols ] || break
      printf "%s " ${header[i]}
    done
    printf "\n"
    cat | sort -n
  } | column -t
}
export -f format_table


get_pdb_header() {
  local -r pdbpath=$1
  shift
  echo "$*" | while read pdb; do
    head -n 1 $PDBDATADIR/${pdb}.pdb | cut -c 11-50 | sed "s/\  */ /g" | sed "s/\"/\\\\\"/g";
  done
}