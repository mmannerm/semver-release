setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'
    DIR="$( cd -- "$(dirname "${BATS_TEST_FILENAME}")" > /dev/null 2>&1 ; pwd -P )"
    SEMVER_SCRIPT=${DIR}/../src/semver-release
}

verify_next_version() {
    local -i major=$2 minor=$3 patch=$4

    source ${SEMVER_SCRIPT}
    next_version "$1" major minor patch

    assert_equal ${major} $5
    assert_equal ${minor} $6
    assert_equal ${patch} $7
}

@test "next_version major" {
    verify_next_version "major" 0 0 0 1 0 0
    verify_next_version "major" 1 7 13 2 0 0
    verify_next_version "major" 9 7 1 10 0 0
    verify_next_version "major" 2 0 0 3 0 0
}

@test "next_version minor" {
    verify_next_version "minor" 0 0 0 0 1 0
    verify_next_version "minor" 1 7 13 1 8 0
    verify_next_version "minor" 9 7 1 9 8 0
    verify_next_version "minor" 2 0 0 2 1 0
}

@test "next_version patch" {
    verify_next_version "patch" 0 0 0 0 0 1
    verify_next_version "patch" 1 7 13 1 7 14
    verify_next_version "patch" 9 7 1 9 7 2
    verify_next_version "patch" 2 0 0 2 0 1
}

@test "next_version fail on invalid scope" {
    local -i major=1 minor=2 patch=3

    source ${SEMVER_SCRIPT}
    run next_version "invalid" major minor patch

    assert_equal $status 1
}

@test "next_version fail on invalid args" {
    local -i major=1 minor=2

    source ${SEMVER_SCRIPT}
    run next_version "invalid" major minor

    assert_equal $status 2
}