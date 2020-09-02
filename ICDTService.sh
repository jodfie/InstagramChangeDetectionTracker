########################################################################
#     Coded by MagicalCodeMonkey for Jodfie                            #
#     Part of Insta Change Detection Tracker (ICDT)                    #
#     https://github.com/jodfie/InstagramChangeDetectionTracker/       #
########################################################################

#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configuration
readonly INSTAGRAM_USERS_FILE="${INSTAGRAM_USERS_FILE:-users.txt}"
readonly INSTATRACK_DIR="${INSTATRACK_DIR:-InstaTrack}"

#######################################################################
#     DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU ARE DOING          #
#######################################################################

readonly DETECTED_PUID=${SUDO_UID:-$UID}
readonly DETECTED_UNAME=$(id -un "${DETECTED_PUID}" 2> /dev/null || true)
readonly DETECTED_HOMEDIR=$(eval echo "~${DETECTED_UNAME}" 2> /dev/null || true)
readonly INSTATRACK_PATH="${DETECTED_HOMEDIR}/${INSTATRACK_DIR}"

readonly diff_file=".diff_file"
readonly diff_results_file=".diff_results"
readonly diff_summary_file=".diff_summary"

echo "Starting script"
echo ""
echo ""
echo "Installing/Updating dependencies..."
pip3 install requests > /dev/null
pip3 install xlwt > /dev/null

if [[ ! -d "${INSTATRACK_PATH}" ]]; then
    echo "Creating ${INSTATRACK_PATH}"
    mkdir -p "${INSTATRACK_PATH}"
fi

if [[ ! -f "${INSTATRACK_PATH}/notifier.sh" ]]; then
    touch "${INSTATRACK_PATH}/notifier.sh"
fi

echo "Changing to '${INSTATRACK_PATH}'"
cd "${INSTATRACK_PATH}"

if [[ ! -f "${INSTATRACK_PATH}/InstaTrackChangeDetection.sh" ]]; then
    echo "Getting latest InstaTrackChangeDetection.sh script"
    curl -sSL https://gist.githubusercontent.com/MagicalCodeMonkey/24a1a4579076a12cda207849b84b9601/raw/InstaTrackChangeDetection.sh -o "${INSTATRACK_PATH}/InstaTrackChangeDetection.sh"
    echo "Done."
    echo "Run 'bash InstaTrackChangeDetection.sh' or '${INSTATRACK_PATH}/InstaTrackChangeDetection.sh' from now on."
    echo "Exiting..."
    exit
fi

echo "Getting latest InstaTrackWithExcelOutput.py script"
curl -sSL https://gist.githubusercontent.com/MagicalCodeMonkey/24a1a4579076a12cda207849b84b9601/raw/InstaTrackWithExcelOutput.py -o "${INSTATRACK_PATH}/InstaTrackWithExcelOutput.py"

if [[ ! -f "${INSTATRACK_PATH}/${INSTAGRAM_USERS_FILE}" ]]; then
    echo "Users file does not exist: '${INSTATRACK_PATH}/${INSTAGRAM_USERS_FILE}'"
    exit 1
fi

if [[ -f "${INSTATRACK_PATH}/results.txt" ]]; then
    mv "${INSTATRACK_PATH}/results.txt" "${INSTATRACK_PATH}/results_previous.txt"
fi

cd "${INSTATRACK_PATH}"
echo "Running 'InstaTrackWithExcelOutput.py'"
python3 InstaTrackWithExcelOutput.py -f "${INSTATRACK_PATH}/${INSTAGRAM_USERS_FILE}"
echo ""
echo "Checking for changes..."
if [[ -f "${INSTATRACK_PATH}/results.txt" && -f "${INSTATRACK_PATH}/results_previous.txt" ]]; then
    echo "$(date +"%F %T")" > "${diff_results_file}"
    if [[ $(diff -y "${INSTATRACK_PATH}/results_previous.txt" "${INSTATRACK_PATH}/results.txt" | tee ${diff_file} | wc -l) > 0 ]]; then
        awk '{
                if($1 == ">" && length($2) != 0)
                    print "USER ADDED"
                else if($2 == "<")
                    print "USER DELETED"
                else if($2 == "|")
                    print "USER CHANGED"
                else
                    print "NO CHANGE"
            }' ${diff_file} > ${diff_results_file}
        add_count=$(grep -c "USER ADDED" "${diff_results_file}" || true)
        chg_count=$(grep -c "USER CHANGED" "${diff_results_file}" || true)
        del_count=$(grep -c "USER DELETED" "${diff_results_file}" || true)
        echo "Users added=${add_count}" | tee -a "${diff_summary_file}"
        echo "Users changed=${chg_count}" | tee -a "${diff_summary_file}"
        echo "Users deleted=${del_count}" | tee -a "${diff_summary_file}"
        # Import code for sending notifications
        source "${INSTATRACK_PATH}/notifier.sh"
    else
        echo "No changes found!" | tee -a "${diff_summary_file}"
    fi
elif [[ -f "${INSTATRACK_PATH}/results.txt" && ! -f "${INSTATRACK_PATH}/results_previous.txt" ]]; then
    echo "It appears this has only been run once. Change detection will start with the next run."
elif [[ ! -f "${INSTATRACK_PATH}/results.txt" && -f "${INSTATRACK_PATH}/results_previous.txt" ]]; then
    echo "Hmmm... Can't find '${INSTATRACK_PATH}/results.txt'"
    echo "Try running this again..."
else
    echo "Hmmm... Can't find '${INSTATRACK_PATH}/results.txt' or '${INSTATRACK_PATH}/results_previous.txt'."
    echo "Something may have gone wrong. Check the output."
fi

echo ""
echo "Finished script"
