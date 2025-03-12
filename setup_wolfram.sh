echo "Working directory is $(pwd)"
SCRIPT_PATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"
source $SCRIPT_PATH/build_scripts/setup_permissions.sh
source $SCRIPT_PATH/build_scripts/expand_path.sh
# ##############################################################################
# Setup mathematica environment
# ##############################################################################

if [[ -z ${option_setup_mathematica+x} ]]; then
  echo
  read -p "Install DiFfRG mathematica package locally? [Y/n] " option_setup_mathematica
  option_setup_mathematica=${option_setup_mathematica:-Y}
fi
if [[ ${option_setup_mathematica} != "n" ]] && [[ ${option_setup_mathematica} != "N" ]]; then
  echo "Checking for mathematica installation..."
  wolfram="wolframscript"
  has_mathematica="n"
  if command -v ${wolfram} &>/dev/null; then
    has_mathematica="y"
  else
    echo "    Mathematica: '${wolfram}' command could not be found"
    read -p "    Provide the path to a valid Mathematica or WolframScript executable: " wolfram
    if command -v ${wolfram} &>/dev/null; then
      has_mathematica="y"
    fi
  fi

  if [[ ${has_mathematica} != "y" ]]; then
    echo "    Mathematica: '${wolfram}' command could not be found"
    exit 1
  else
    # We use the math command to determine the mathematica applications folder
    math_app_folder=$($wolfram -code 'FileNameJoin[{$UserBaseDirectory,"Applications"}]//Print;Exit[]' | tail -n1)
    mkdir -p ${math_app_folder}

    echo "  DiFfRG mathematica package will be installed to ${math_app_folder}"

    # Check if a DiFfRG mathematica package is already installed
    if [[ -d ${math_app_folder}/DiFfRG ]]; then
      echo "    DiFfRG mathematica package already installed in ${math_app_folder}"
      read -p "    Do you want to overwrite it? [y/N] " option_overwrite_mathematica
      option_overwrite_mathematica=${option_overwrite_mathematica:-N}
      if [[ ${option_overwrite_mathematica} == "n" ]] || [[ ${option_overwrite_mathematica} == "N" ]]; then
        echo "    Aborting."
        exit 0
      fi
      rm -rf ${math_app_folder}/DiFfRG
    fi

    # Copy the DiFfRG mathematica package to the mathematica applications folder
    echo "  Installing DiFfRG mathematica package to ${math_app_folder}"
    cp -r ${SCRIPT_PATH}/Mathematica/DiFfRG ${math_app_folder} || {
      echo "    Failed to install DiFfRG mathematica package, aborting."
      exit 1
    }
  fi

  echo
fi
