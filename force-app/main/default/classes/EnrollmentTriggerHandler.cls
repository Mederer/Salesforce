public with sharing class EnrollmentTriggerHandler extends AbstractTriggerHandler {
  public override String getHandlerName() {
    return 'EnrollmentTriggerHandler';
  }

  public override void beforeInsert(List<SObject> newList) {
    EnrollmentService.confirmOrWaitlist(newList);
  }

  public override void afterInsert(List<SObject> newList) {
    EnrollmentService.createSubjectProgressRecords(newList);
  }

  public override void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> oldMap
  ) {
  }

  public override void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> oldMap
  ) {
    List<Enrollment__c> cancelledEnrollments = new List<Enrollment__c>();
    for (Enrollment__c enrollment : (List<Enrollment__c>) newList) {
      Enrollment__c oldEnrollment = (Enrollment__c) oldMap.get(enrollment.Id);
      if (
        oldEnrollment.Status__c != 'Cancelled' &&
        enrollment.Status__c == 'Cancelled'
      ) {
        cancelledEnrollments.add(enrollment);
      }
    }
    EnrollmentService.promoteWaitlist(cancelledEnrollments);
  }

  public override void beforeDelete(List<SObject> oldList) {
  }

  public override void afterDelete(List<SObject> oldList) {
  }
}
