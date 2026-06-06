public with sharing class TestClass {
    private String name;

    public TestClass() {
        this('name');
    }

    public TestClass(String name) {
        this.name = name;
    }

    public void printName() {
        System.debug(LoggingLevel.INFO, 'Your name is ' + this.name  + '. Thanks for playing');
    }
}