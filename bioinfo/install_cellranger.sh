#!/usr/bin/env bash

# Download needs authorization acquired from:
# + https://support.10xgenomics.com/single-cell-gene-expression/software/downloads/latest?

function _install_cellranger () {
  local _version_string=6.1.2;

# E.g. Probably will not work next time
# curl -o cellranger-6.1.2.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-6.1.2.tar.gz?Expires=1647403679&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci02LjEuMi50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NDc0MDM2Nzl9fX1dfQ__&Signature=RvNcDBg-9tr2V7cZiObmzLBSD-vtOi7PD49VGUjsBFjyPMWIj7IbbF3tc6AOkFbp0oS9Uanyc1tANBzLBQ7IGtDGqJ6saY39PDwuhRyy3Tk24rFdOQ4aJU5W4k7aBgw6qoZF3rEODX-2RoNxtS-i~tMrlrxWsmYd1xGPl4iI0AQ-SXDSwJKERyhkMs3ikWYEr-34mam2iBPZOuVIZB8e~hNFKFyh6jxLp2Wly~sEj53BCuFNe66jiQADYKSF5ISUwY5rEzXGmfh0B8T2PreF5VFkHzPTckc8UTwJFqlttfxyw8868C4st52NoUL0U9sH-G7qt~aELH~hEz5lvRbOHA__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"

# or
  curl -o cellranger-6.1.2.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-6.1.2.tar.gz?Expires=1641366506&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1leHAvY2VsbHJhbmdlci02LjEuMi50YXIuZ3oiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2NDEzNjY1MDZ9fX1dfQ__&Signature=kaV8~ZabHhyDykUhbN~F78PDQfNZ64IamgsGc1nOSghFKPr0fbZ3WJk-2eWYh7IEt-KupenYP89W1zHi4lrxF~ZBbuP4NTaKEAa-G6ILJoX-VdyFnktkXFYDHgzEJ8ABq-NM6RWn20WD3a9BITNHTIWPtxjM-NaXAuR5uc5PuAEgjSDaQ2QBAQr~1q4aSM-~vJt~ia5e8acTz9RlM24EluLqfO59VCtAorP-5iJRwvLw9DjfrTlDtWfy3M2LSXp5OGmVJH1WUQReLK~0iZX2e8~vrHlAYpuxMa0Lgil6oHQ5s6vc~Dod3Aqpjb9sM~wuVo80zi4EqJ5nq0LU8SNbiQ__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"



  sudo mkdir -p /opt/apps/bioinfo/cellranger

  tar -zxvf cellranger-${_version_string}.tar.gz

  sudo mv cellranger-${_version_string} /opt/apps/bioinfo/cellranger/

  sudo ln -sf /usr/local/bin/cellranger /opt/apps/bioinfo/cellranger/cellranger-${_version_string}/cellranger /usr/local/bin/cellranger

  ulimit -a;
  ulimit -n;
  echo -ne "Check 'open files' limit with 'ulimit -n', it should be at least '16000'.\n";
  echo -ne "Check '_change_limits' function on 'shell-lib' for a definitive change guide.\n";
}


