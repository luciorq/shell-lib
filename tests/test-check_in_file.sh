#!/usr/bin/env bats

set -euxo pipefail

# Pass
source utils/mac_utils.sh; check_in_file 'auth sufficient pam_tid.so' tests/check_in_file.txt

