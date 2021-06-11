setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'
    DIR="$( cd -- "$(dirname "${BATS_TEST_FILENAME}")" > /dev/null 2>&1 ; pwd -P )"
    SEMVER_SCRIPT=${DIR}/../src/semver-release
}

verify_parse_version() {
    local -i major minor patch
    local prerelease build

    source ${SEMVER_SCRIPT}
    parse_version "$1" major minor patch prerelease build

    assert_equal ${major} $2
    assert_equal ${minor} $3
    assert_equal ${patch} $4
    assert_equal ${prerelease} $5
    assert_equal ${build} $6
}

assert_fail_parse_version() {
    local -i major minor patch
    local prerelease build

    source ${SEMVER_SCRIPT}
    run parse_version "$1" major minor patch prerelease build

    assert_equal ${status} 1

    assert_equal ${major} ""
    assert_equal ${minor} ""
    assert_equal ${patch} ""
    assert_equal ${prerelease} ""
    assert_equal ${build} ""
}

@test "parse_version major.minor.patch-prerelease+build" {
    verify_parse_version "1.7.13-pr-4.1+b1.2.3" 1 7 13 pr-4.1 b1.2.3
    verify_parse_version "0.0.0-pr4+b1" 0 0 0 pr4 b1
    verify_parse_version "12.7.3-b12+b3" 12 7 3 b12 b3
    verify_parse_version "0.17.9-pr+b" 0 17 9 pr b
}

@test "parse_version major.minor.patch-prerelease" {
    verify_parse_version "1.7.13-pr-4.1-1" 1 7 13 pr-4.1-1 ""
    verify_parse_version "0.0.0-pr-4-1" 0 0 0 pr-4-1 ""
    verify_parse_version "12.7.3-b12" 12 7 3 b12 ""
    verify_parse_version "0.17.9--" 0 17 9 - ""
}

@test "parse_version major.minor.patch+build" {
    verify_parse_version "1.7.13+b1.-.3" 1 7 13 "" b1.-.3
    verify_parse_version "0.0.0+b-1" 0 0 0 "" b-1
    verify_parse_version "12.7.3+3b" 12 7 3 "" 3b
    verify_parse_version "0.17.9+-" 0 17 9 "" -
}

@test "parse_version major.minor.patch only" {
    verify_parse_version "1.7.13" 1 7 13 "" ""
    verify_parse_version "0.0.0" 0 0 0 "" ""
    verify_parse_version "12.7.3" 12 7 3 "" ""
    verify_parse_version "0.17.9" 0 17 9 "" ""
}

@test "parse_version fail on invalid args" {
    local -i major minor patch
    local prerelease

    source ${SEMVER_SCRIPT}
    run parse_version "" major minor patch prerelease

    assert_equal $status 2
}

@test "parse_version fail on invalid version" {
    assert_fail_parse_version ""
    assert_fail_parse_version "invalid"
    assert_fail_parse_version ".."
    assert_fail_parse_version "..-+"
    assert_fail_parse_version "a.b.c"
    assert_fail_parse_version "01.1.1"
    assert_fail_parse_version "1.1.1+\\"
    assert_fail_parse_version "1.1.1++"
    assert_fail_parse_version "1.1.1 -test"

    # These would require support for (?:) in bash regex
    #assert_fail_parse_version "1.1.1-"
    #assert_fail_parse_version "1.1.1+"
    #assert_fail_parse_version "1.1.1-+"
}
