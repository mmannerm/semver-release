setup() {
    load 'lib/bats-support/load'
    load 'lib/bats-assert/load'
    DIR="$( cd -- "$(dirname "${BATS_TEST_FILENAME}")" > /dev/null 2>&1 ; pwd -P )"
    SEMVER_SCRIPT=${DIR}/../src/semver-release
}

verify_auto_scope() {
    local scope

    source ${SEMVER_SCRIPT}
    auto_scope scope

    assert_equal ${scope} $1
}

@test "auto_scope not a git repository" {
    local scope

    cd $BATS_TEST_TMPDIR/

    source ${SEMVER_SCRIPT}
    run auto_scope scope

    assert_equal $status 1
}

@test "auto_scope no arguments" {
    cd $BATS_TEST_TMPDIR/

    source ${SEMVER_SCRIPT}
    run auto_scope

    assert_equal $status 2
}

@test "auto_scope no commits" {
    local scope

    cd $BATS_TEST_TMPDIR/
    git init -b master

    source ${SEMVER_SCRIPT}
    run auto_scope scope

    assert_equal $status 1
}

@test "auto_scope single commit" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"

    verify_auto_scope "minor"
}

@test "auto_scope only a tag but no merge branches" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git tag -a 1.0.0 -m "1.0.0"
    touch test2
    git add test2
    git commit -a -m "Test2"

    verify_auto_scope "minor"
}

@test "auto_scope does not use tags from other branches" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git tag -a 1.0.0 -m "1.0.0"
    git checkout -b patch/branch2
    touch test2
    git add test2
    git commit -a -m "Test2"
    git tag -a 1.0.1 -m "1.0.1"
    git checkout master
    git merge --no-ff patch/branch2

    verify_auto_scope "patch"
}

@test "auto_scope merge branch feature/xxx" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git checkout -b feature/xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff feature/xxx

    verify_auto_scope "minor"
}

@test "auto_scope merge branch minor/xxx" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git checkout -b minor/xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff minor/xxx

    verify_auto_scope "minor"
}

@test "auto_scope merge branch major/xxx" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git checkout -b major/xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff major/xxx

    verify_auto_scope "major"
}

@test "auto_scope merge branch bugfix/xxx" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git checkout -b bugfix/xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff bugfix/xxx

    verify_auto_scope "patch"
}

@test "auto_scope merge branch fix_xxx" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git checkout -b fix_xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff fix_xxx

    verify_auto_scope "patch"
}

@test "auto_scope merge branch patch-xxx" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"
    git checkout -b patch-xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff patch-xxx

    verify_auto_scope "patch"
}

@test "auto_scope minor wins patch" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"

    git checkout -b patch-xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff patch-xxx

    git checkout -b minor-yyy
    touch test3
    git add test3
    git commit -a -m "Test3"
    git checkout master
    git merge --no-ff minor-yyy

    git checkout -b patch-zzz
    touch test4
    git add test4
    git commit -a -m "Test4"
    git checkout master
    git merge --no-ff patch-zzz

    verify_auto_scope "minor"
}

@test "auto_scope major wins minor and patch" {
    cd $BATS_TEST_TMPDIR/
    git init -b master
    touch test
    git add test
    git commit -a -m "Test"

    git checkout -b major/xxx
    touch test2
    git add test2
    git commit -a -m "Test2"
    git checkout master
    git merge --no-ff major/xxx

    git checkout -b minor-yyy
    touch test3
    git add test3
    git commit -a -m "Test3"
    git checkout master
    git merge --no-ff minor-yyy

    git checkout -b patch/zzz
    touch test4
    git add test4
    git commit -a -m "Test4"
    git checkout master
    git merge --no-ff patch/zzz

    verify_auto_scope "major"
}

