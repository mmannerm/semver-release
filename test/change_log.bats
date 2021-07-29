setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'
    DIR="$( cd -- "$(dirname "${BATS_TEST_FILENAME}")" > /dev/null 2>&1 ; pwd -P )"
    SEMVER_SCRIPT=${DIR}/../src/semver-release
}

verify_change_log() {
    local _log

    source ${SEMVER_SCRIPT}
    change_log _log

    echo "# log: '${_log}'" >&3

    run echo "${_log}"
    assert_output --partial $1
}

@test "change_log not a git repository" {
    local _log

    cd $BATS_TEST_TMPDIR/

    source ${SEMVER_SCRIPT}
    run change_log _log

    assert_equal $status 1
}

@test "change_log no arguments" {
    cd $BATS_TEST_TMPDIR/

    source ${SEMVER_SCRIPT}
    run change_log

    assert_equal $status 2
}

@test "change_log no commits" {
    local _log

    cd $BATS_TEST_TMPDIR/
    git init -b master

    source ${SEMVER_SCRIPT}
    run change_log _log

    assert_equal $status 1
}

@test "change_log single commit" {
    local _log

    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"

    source ${SEMVER_SCRIPT}
    change_log _log
    run echo "${_log}"
    assert_output --partial "Test"
}

@test "change_log only a tag but no merge branches" {
    local _log

    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "First"
    git tag -a 1.0.0 -m "1.0.0"
    touch test2
    git add test2
    git commit -a -m "Second"

    source ${SEMVER_SCRIPT}
    change_log _log
    run echo "${_log}"
    assert_output --partial "Second"
    refute_output --partial "First"
}

@test "change_log does not use tags from other branches" {
    local _log

    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "First"
    git tag -a 1.0.0 -m "1.0.0"
    git checkout -b patch/branch2
    touch test2
    git add test2
    git commit -a -m "Second"
    git tag -a 1.0.1 -m "1.0.1"
    git checkout master
    git merge --no-ff patch/branch2

    source ${SEMVER_SCRIPT}
    change_log _log
    run echo "${_log}"
    assert_output --partial "Second"
    refute_output --partial "First"
}

@test "change_log includes multiple commits even if merge commit exists" {
    local _log

    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "First"
    git checkout -b patch/branch2
    touch test2
    git add test2
    git commit -a -m "Second"
    git checkout master
    git merge --no-ff patch/branch2

    source ${SEMVER_SCRIPT}
    change_log _log
    run echo "${_log}"
    assert_output --partial "Second"
    assert_output --partial "First"
}
