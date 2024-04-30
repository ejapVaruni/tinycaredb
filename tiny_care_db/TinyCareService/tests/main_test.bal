import ballerina/test;

@test:Config {}
function envDbTest() {
    test:assertEquals(4, 4);
}