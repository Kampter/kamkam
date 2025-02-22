#[test_only]
module kamkam::template_tests;
// uncomment this line to import the module
// use template::template;

const ENotImplemented: u64 = 0;

#[test]
fun test_template() {
    // pass
}

#[test, expected_failure(abort_code = ::kamkam::template_tests::ENotImplemented)]
fun test_template_fail() {
    abort ENotImplemented
}
