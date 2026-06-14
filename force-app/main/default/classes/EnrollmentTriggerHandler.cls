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
    EnrollmentService.promoteWaitlist(getCancelledEnrollments(newList, oldMap));
  }

  public override void beforeDelete(List<SObject> oldList) {
  }

  public override void afterDelete(List<SObject> oldList) {
  }

  private List<Enrollment__c> getCancelledEnrollments(
    List<SObject> newList,
    Map<Id, SObject> oldMap
  ) {
    List<Enrollment__c> cancelledEnrollments = new List<Enrollment__c>();
    for (Enrollment__c enrollment : (List<Enrollment__c>) newList) {
      Enrollment__c oldEnrollment = (Enrollment__c) oldMap.get(enrollment.Id);
      if (
        oldEnrollment.Status__c != EnrollmentService.CANCELLED &&
        enrollment.Status__c == EnrollmentService.CANCELLED
      ) {
        cancelledEnrollments.add(enrollment);
      }
    }
    return cancelledEnrollments;
  }
}
