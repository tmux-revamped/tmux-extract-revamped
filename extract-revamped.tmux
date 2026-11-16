#!/bin/sh

extract_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${extract_revamped_dir}/bin/extract-revamped" apply
