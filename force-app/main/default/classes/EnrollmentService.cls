public with sharing class EnrollmentService {
  public static void confirmOrWaitlist(List<Enrollment__c> enrollments) {
    Set<Id> courseSessionIds = new Set<Id>();
    // Track confirms within this batch to avoid over-confirming
    Map<Id, Integer> batchConfirmedCount = new Map<Id, Integer>();

    for (Enrollment__c enrollment : enrollments) {
      courseSessionIds.add(enrollment.Course_Session__c);
    }

    Map<Id, Course_Session__c> sessions = new Map<Id, Course_Session__c>(
      [
        SELECT Id, Max_Seats__c, Confirmed_Enrollments__c
        FROM Course_Session__c
        WHERE Id IN :courseSessionIds
      ]
    );

    for (Enrollment__c enrollment : enrollments) {
      Course_Session__c session = sessions.get(enrollment.Course_Session__c);
      if (session != null) {
        Integer maxSeats = session.Max_Seats__c != null
          ? Integer.valueOf(session.Max_Seats__c)
          : 0;
        Integer confirmedInDb = session.Confirmed_Enrollments__c != null
          ? Integer.valueOf(session.Confirmed_Enrollments__c)
          : 0;
        Integer confirmedInBatch = batchConfirmedCount.containsKey(session.Id)
          ? batchConfirmedCount.get(session.Id)
          : 0;

        if (confirmedInDb + confirmedInBatch < maxSeats) {
          enrollment.Status__c = 'Confirmed';
          batchConfirmedCount.put(session.Id, confirmedInBatch + 1);
        } else {
          enrollment.Status__c = 'Waitlisted';
        }
      }
    }
  }

  // public static void createSubjectProgressRecords(List<Enrollment__c> enrollments) {
  //     Set<Id> sessionIds = new Set<Id>();

  //     for (Enrollment__c enrollment: enrollments) {
  //         sessionIds.add(enrollment.Course_Session__c);
  //     }

  //     Set<Id, Id> sessionIdToCourseId = new Set<Id, Id>();
  //     for (Course_Session__c session: [
  //         SELECT Id, Course__c
  //         FROM Course_Session__c
  //         WHERE Id IN :sessionIds
  //     ]) {
  //         sessionIdToCourseId.put(session.Id, session.Course__c);
  //     }

  //     Map<Id, List<Course_Subject__>> courseIdToSubjects = new Map<Id, List<Course_Subject__c>>();
  //     for (Course_Subject__c courseSubject: [

  //     ])
  // }
}
