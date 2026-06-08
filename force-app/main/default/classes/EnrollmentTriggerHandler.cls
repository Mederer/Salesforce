public with sharing class EnrollmentTriggerHandler extends AbstractTriggerHandler {
  public override String getHandlerName() {
    return 'EnrollmentTriggerHandler';
  }

  public override void beforeInsert(List<SObject> newList) {
  }

  public override void afterInsert(List<SObject> newList) {
    EnrollmentService.confirmOrWaitlist(newList);
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
  }

  public override void beforeDelete(List<SObject> oldList) {
  }

  public override void afterDelete(List<SObject> oldList) {
  }
}
