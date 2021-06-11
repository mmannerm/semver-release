setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'
    DIR="$( cd -- "$(dirname "${BATS_TEST_FILENAME}")" > /dev/null 2>&1 ; pwd -P )"
    SEMVER_SCRIPT=${DIR}/../src/semver-release
}

verify_get_version() {
    local version

    source ${SEMVER_SCRIPT}
    get_version version

    assert_equal ${version} $1
}

@test "get_version default version is 0.0.0" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"

    verify_get_version "0.0.0"
}

@test "get_version from latest tag even if commits after the tag" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git tag -a 1.0.0 -m "1.0.0"
    touch test2
    git add test2
    git commit -a -m "Test2"

    verify_get_version "1.0.0"
}

@test "get_version does not use tags from other branches" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git tag -a 1.0.0 -m "1.0.0"
    git checkout -b branch2
    touch test2
    git add test2
    git commit -a -m "Test2"
    git tag -a 1.0.1 -m "1.0.1"
    git checkout master
    git merge --no-ff branch2

    verify_get_version "1.0.0"
}

@test "has_tag on commit with tag" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git tag -a 1.0.0 -m "1.0.0"

    verify_get_version "1.0.0"
    run has_tag
    assert_success
}

@test "has_tag on commit without a tag" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git tag -a 1.0.0 -m "1.0.0"
    touch test2
    git add test2
    git commit -a -m "Test2"

    verify_get_version "1.0.0"
    run has_tag
    assert_failure
}
