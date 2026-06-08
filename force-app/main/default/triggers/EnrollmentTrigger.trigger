trigger EnrollmentTrigger on Enrollment__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  new EnrollmentTriggerHandler().run();
}
