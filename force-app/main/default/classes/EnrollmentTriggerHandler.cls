public with sharing class EnrollmentTriggerHandler implements ITriggerHandler {
    public static Boolean bypassTrigger = false;

    public void beforeInsert(List<SObject> newList) {
        System.debug(LoggingLevel.INFO, 'Before insert of Enrollment.');
    }
    
    public void afterInsert(List<SObject> newList) {}
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public void beforeDelete(List<SObject> oldList) {}
    public void afterDelete(List<SObject> oldList) {}
}