#!/bin/bash

# This is an argument parser that dumps the results into two arrays.
#
# A wrapper is provided that splits the arguments properly first.

# Checks if the type of a variable matches the specified type
#
# 1.variable the name of the variable to check
# 2.type the desired type of the variable
checkType() {
  local -r variable="$1"
  local -r type="$2"

  declare -p "$variable" 2>/dev/null | grep -qE "^declare -$type"
  return $?
}

# resplit the passed parameters taking into account quoting
#
# &0. The input arguments to split then parse 
aacmdparsesplit() {
  local -a splitArgs=()
  while IFS= read -r -d $'\0' arg; do
    splitArgs[i++]="$arg"
  done < <(printf "%s " "$@" | sed 's/ $//' | gawk -f "$depDir/resplit.awk")
  aacmdparse "${splitArgs[@]}"
}

# Parses the input arguments into a hashmap
#
# Any found parameters are placed into the argMap associative array
# The remaining arguments are placed into the vargs array
#
# @. the arguments to parse
aacmdparse() {
  local arg
  local getNext=false
  local previous
  local i
  local -A parameterSet=()

  local hasExtGlob=false
  if shopt -q extglob; then
    hasExtGlob=true
  else
    shopt -s extglob
  fi

  local char
  local parameterName

  if checkType assignableParameters a; then
    for parameter in "${assignableParameters[@]}"; do
      parameterSet["$parameter"]=
    done
  fi

  local -r shortOption="-+([a-zA-Z])"
  local -r longOption="--+([a-zA-Z])"

  if checkType argMap A && checkType vargs a; then

    argMap=()
    vargs=()

    while (($# > 0)); do
      arg="$1"
      shift
      
      case "$arg" in
        $shortOption )
          if "$getNext"; then
            argMap["$previous"]=
          fi

          if ((${#arg} == 2)); then
            char="${arg:1:1}"
            if [[ -n "${!parameterSet[@]}" ]] && [[ "${parameterSet[$char]+_}" ]]; then
              previous="$char"
              getNext=true
            else
              argMap["$char"]=
              previous=
              getNext=false
            fi
          else
            previous=
            getNext=false
            # the following code is safe due to the invariant that i is [a-zA-Z]{1}
            for i in $(grep -o . <<< "${arg#-}"); do
              if [[ -n "$previous" ]]; then
                argMap["$previous"]=
              fi
              if [[ -n "${!parameterSet[@]}" ]] && [[ "${parameterSet[$i]+_}" ]]; then
                previous="$i"
                getNext=true
              else
                argMap["$i"]=
                previous=
                getNext=false
              fi
            done
          fi
          ;;
        -- ) 
          if "$getNext"; then
            argMap["$previous"]=
            previous=
            getNext=false
          fi
          vargs+=( "$@" )
          break
          ;;
        $longOption )
          if "$getNext"; then
            argMap["$previous"]=
          fi
          parameterName="${arg#--}"
          if [[ -n "${parameterSet[@]}" ]] && [[ "${parameterSet[$char]+_}" ]]; then
            previous="$parameterName"
            getNext=true 
          else
            previous=
            getNext=false 
            argMap["$parameterName"]=
          fi
          ;;
        * )
          if "$getNext"; then
            argMap["$previous"]="$arg"
            previous=
            getNext=false
          else
            vargs+=( "$arg" )
          fi
          ;;
      esac
           
    done
    if "$getNext"; then
      argMap["$previous"]=
    fi
  else
    return 1
  fi

  if ! "$hasExtGlob"; then
    shopt -u extglob
  fi
}

if [[ ${BASH_SOURCE[0]} == $0 ]]; then
  cat >&2 <<EOF
aacmdparse is strictly a bash library and has no obvious functionality as a runtime program.

Use it by first sourcing it in a script or on the command line with "source aacmdparse" then call it in one of the following forms:

    aacmdparsesplit <<< "\$@"

Which takes input on stdin and splits it emulating bash command splitting. Be careful not to accidentally call it in a subshell by putting it in a pipeline.
  
    aacmpdparse "\$@"

Which parses the commands passed as args. aacmdparsesplit just splits the input then calls this form.
EOF
  exit 1
fi

declare -r depDir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )" 

declare -A argMap=()
declare -a vargs=()

export -f aacmdparse
export -f aacmdparsesplit
export argMap
export vargs
