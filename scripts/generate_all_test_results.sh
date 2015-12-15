#!/bin/bash
set -e -u -o pipefail # Safety first!

# Parse arguments
update=false
cleanup=true
verbose=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --update) update=true ;;
        --leave-a-mess) cleanup=false ;;
        --verbose) verbose=true ;;
        *) echo "Unknown argument: $1"; exit 1;;
    esac
    shift
done

echo "You ran \`cd src && make && make test\` before this, right?  I'll trust that you did."

gotcloud_root="$(dirname "$(dirname "$0")")"
gotcloud_executable="$gotcloud_root/gotcloud"
echo "using $gotcloud_executable"

# Pathname length affects tabix files.  Hopefully this reduces change.
outdir="$(mktemp -d --tmpdir "gotcloud-tests-$USER-XXX")"
echo "outputting to $outdir"

child_pids=""

# Note: These three commands are independent of each other, so we'll run them all in parallel.

cmds1="align indel bamQC recabQC"
for cmd in $cmds1; do
    # TODO: quote the commands in this command
    bash -c "$gotcloud_executable $cmd --test $outdir/$cmd &> $outdir/$cmd.output; echo \$? > $outdir/$cmd.return_status; echo \$(date) finished $cmd;" &
    child_pids+=" $!"
done

set +e

# Note: ldrefine is beagle + thunder, and beagle4 is `umake --split4` + `umake --beagle4`
# Note: all tests are run in `umaketest`, because the name of the working directory must stay consistent through the whole process.
# TODO: run ldrefine and beagle4 in parallel

cmds2="snpcall beagle thunder split4 beagle4"
for cmd in $cmds2; do
    "$gotcloud_root/bin/umake.pl" --$cmd --test "$outdir/umaketest" &> "$outdir/$cmd.output"
    echo $? > "$outdir/$cmd.return_status"
    cp "$outdir/umaketest/umaketest.log" "$outdir/$cmd.log"
    echo "$(date) finished $cmd"
done

set -e

for child_pid in $child_pids; do
    wait $child_pid
done

status=0

for cmd in $cmds1 $cmds2; do
    cmd_status="$(cat "$outdir/$cmd.return_status")"
    printf "%-10s %4d\n" "$cmd" "$cmd_status"
done
echo

for cmd in $cmds1; do
    cmd_status="$(cat "$outdir/$cmd.return_status")"
    if [[ $cmd_status != 0 ]]; then
        status="$cmd_status"
        echo "output of failing command $cmd:"
        cat "$outdir/$cmd.output"
        echo
        echo "diff results:"
        if [[ $cmd = align ]]; then
            head -n40 "$outdir/$cmd/diff_logfiles_results.txt"
        else
            head -n40 "$outdir/$cmd/${cmd}test/diff_logfiles_results.txt"
        fi
        echo
    fi
done

for cmd in $cmds2; do
    cmd_status="$(cat "$outdir/$cmd.return_status")"
    if [[ $cmd_status != 0 ]]; then
        status="$cmd_status"
        echo "output of failing command $cmd:"
        cat "$outdir/$cmd.output"
        echo
        echo "log files for failing command $cmd:"
        cat "$outdir/$cmd.log"
        echo
        if [[ $verbose = true ]]; then
            echo "diff results:"
            cat "$outdir/umaketest/diff_logfiles_results_$cmd.txt"
            echo
        fi
    fi
done

if [[ $update = true ]]; then
    echo
    echo updating tests:
    "$gotcloud_root/scripts/update_tests.sh" "$outdir"
    echo
    echo "status:"
    git status
    if [[ $verbose = true ]]; then
        echo
        echo "first 100 lines of diff stat:"
        set +e # This command may return a non-zero status
        git diff --stat | head -n100
        echo
        echo first 100 lines of diff:
        git diff -U0 --word-diff | head -n100
        set -e
    fi
fi

if [[ $cleanup = true ]]; then
    if [[ $status != 0 ]]; then
        echo
        echo "not cleaning up because of non-zero return status"
    else
        echo
        echo "cleaning up"
        rm -r "$outdir"
    fi
fi

if [[ $status = 0 ]]; then
    echo
    echo "'gotcloud test' succeeded!"
else
    echo
    echo "'gotcloud test' failed with status $status."
fi

exit "$status"
