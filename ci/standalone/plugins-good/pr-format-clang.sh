#!/usr/bin/env bash

##
# @file pr-format-clang.sh
# @brief Check Check the code formatting style with clang-format
#


##
#  @brief [MODULE] CI/pr-format-clang
function pr-format-clang(){
    echo "########################################################################################"
    echo "[MODULE] CI/pr-format-clang: Check the code formatting style with clang-format"
    # Note that you have to install up-to-date clang-format package from llvm project.
    # The clang-format-4.0 package includes git-clang-format as well as clang-format.
    # It has been included by http://archive.ubuntu.com/ubuntu/ by default since Oct-25-2017.
    # $ sudo apt install clang-format-4.0
    # In case that we need to change clang-format with latest version, refer to https://apt.llvm.org
    CLANGFORMAT=NA
    CLANG_COMMAND="clang-format-4.0"

    which ${CLANG_COMMAND}
    if [[ $? -ne 0 ]]; then
        echo "Error: ${CLANG_COMMAND} is not available."
        echo "       Please install ${CLANG_COMMAND}."
        exit 1
    fi

    FILES_IN_COMPILER=$(find $SRC_PATH/ -iname '*.h' -o -iname '*.cpp' -o -iname '*.c' -o -iname '*.hpp')
    FILES_TO_BE_TESTED=$(git ls-files $FILES_IN_COMPILER)

    ln -sf ci/doc/.clang-format .clang-format
    ${CLANG_COMMAND} -i $FILES_TO_BE_TESTED
    clang_format_file="clang-format.patch"
    git diff > ../report/${clang_format_file}
    PATCHFILE_SIZE=$(stat -c%s ../report/${clang_format_file})
    if [[ $PATCHFILE_SIZE -ne 0 ]]; then
            echo "[DEBUG] Format checker is failed. Update your code to follow convention after reading ${clang_format_file}."
            check_result="failure"
            global_check_result="failure"
    else
            check_result="success"
    fi

    if [[ $check_result == "success" ]]; then
        echo "[DEBUG] Passed. A clang-formatting style."
        /usr/bin/curl -H "Content-Type: application/json" \
         -H "Authorization: token "$TOKEN"  " \
         --data "{\"state\":\"success\",\"context\":\"CI/pr-format-clang\",\"description\":\"Successfully, The commits are passed.\",\"target_url\":\"${CISERVER}/${PROJECT}/ci/${dir_commit}/report/${clang_format_file}\"}" \
         ${GITHUB_WEBHOOK_API}/statuses/$input_commit
    else
        echo "[DEBUG] Failed. A clang-formatting style."
        /usr/bin/curl -H "Content-Type: application/json" \
         -H "Authorization: token "$TOKEN"  " \
         --data "{\"state\":\"failure\",\"context\":\"CI/pr-format-clang\",\"description\":\"Oooops. The component you are submitting with incorrect clang-format style.\",\"target_url\":\"${CISERVER}/${PROJECT}/ci/${dir_commit}/report/${clang_format_file}\"}" \
         ${GITHUB_WEBHOOK_API}/statuses/$input_commit
fi



}

