#!/usr/bin/env bash

# Strict mode
set -euxo pipefail

# pass
source is_available.sh; is_available ls;
source is_available.sh; is_available /bin/ls;
source is_available.sh; is_available ls -lah;
# fail
source is_available.sh; is_available /randompath/1234/ls;
source is_available.sh; is_available "/random path/1234/ls";
source is_available.sh; is_available 'ls -lah';


# tests/test-which_bin.sh
#!/usr/bin/env bash
# pass
source which_bin.sh; which_bin ls;
source which_bin.sh; which_bin ls -lah;
# fail
source which_bin.sh; which_bin '/randompath/1234/ls';
source which_bin.sh; which_bin '/random path/1234/ls';
source which_bin.sh; which_bin 'ls -lah';
source which_bin.sh; which_bin "ls -lah";



# tests/test-check_installed.sh
#!/usr/bin/env bash
# pass
source check_installed.sh; check_installed ls;
source check_installed.sh; check_installed ls -lah;
source check_installed.sh; check_installed "ls -lah";
source check_installed.sh; check_installed 'ls -lah';
source check_installed.sh; check_installed '/bin/ls -lah';

# fail
