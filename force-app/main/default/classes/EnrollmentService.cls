public with sharing class EnrollmentService {
  public static final String CONFIRMED = 'Confirmed';
  public static final String WAITLISTED = 'Waitlisted';
  public static final String CANCELLED = 'Cancelled';
  public static final String NOT_STARTED = 'Not Started';

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
          enrollment.Status__c = CONFIRMED;
          batchConfirmedCount.put(session.Id, confirmedInBatch + 1);
        } else {
          enrollment.Status__c = WAITLISTED;
        }
      }
    }
  }

  public static void createSubjectProgressRecords(
    List<Enrollment__c> enrollments
  ) {
    Set<Id> sessionIds = new Set<Id>();
    List<Subject_Progress__c> progressToInsert = new List<Subject_Progress__c>();

    for (Enrollment__c enrollment : enrollments) {
      sessionIds.add(enrollment.Course_Session__c);
    }

    Map<Id, Id> sessionIdToCourseId = new Map<Id, Id>();
    for (Course_Session__c session : [
      SELECT Id, Course__c
      FROM Course_Session__c
      WHERE Id IN :sessionIds
    ]) {
      sessionIdToCourseId.put(session.Id, session.Course__c);
    }

    Map<Id, List<Course_Subject__c>> courseIdToSubjects = new Map<Id, List<Course_Subject__c>>();
    for (Course_Subject__c courseSubject : [
      SELECT Id, Course__c, Subject__c
      FROM Course_Subject__c
      WHERE Course__c IN :sessionIdToCourseId.values()
    ]) {
      if (!courseIdToSubjects.containsKey(courseSubject.Course__c)) {
        courseIdToSubjects.put(
          courseSubject.Course__c,
          new List<Course_Subject__c>()
        );
      }
      courseIdToSubjects.get(courseSubject.Course__c).add(courseSubject);
    }

    for (Enrollment__c enrollment : enrollments) {
      Id courseId = sessionIdToCourseId.get(enrollment.Course_Session__c);
      List<Course_Subject__c> subjects = courseIdToSubjects.get(courseId);

      if (subjects != null) {
        for (Course_Subject__c subject : subjects) {
          Subject_Progress__c progress = new Subject_Progress__c();
          progress.Enrollment__c = enrollment.Id;
          progress.Course_Subject__c = subject.Id;
          progress.Subject__c = subject.Subject__c;
          progress.Status__c = NOT_STARTED;
          progressToInsert.add(progress);
        }
      }
    }

    if (!progressToInsert.isEmpty()) {
      insert progressToInsert;
    }
  }

  public static void promoteWaitlist(List<Enrollment__c> cancelledEnrollments) {
    Set<Id> sessionIds = new Set<Id>();
    for (Enrollment__c enrollment : cancelledEnrollments) {
      sessionIds.add(enrollment.Course_Session__c);
    }

    Map<Id, Course_Session__c> sessions = new Map<Id, Course_Session__c>(
      [
        SELECT Id, Max_Seats__c, Confirmed_Enrollments__c
        FROM Course_Session__c
        WHERE Id IN :sessionIds
      ]
    );

    // Stack per session: most recently waitlisted enrollment at index 0 (top)
    Map<Id, List<Enrollment__c>> waitlistBySession = new Map<Id, List<Enrollment__c>>();
    for (Enrollment__c waitlisted : [
      SELECT Id, Course_Session__c
      FROM Enrollment__c
      WHERE Course_Session__c IN :sessionIds AND Status__c = :WAITLISTED
      ORDER BY CreatedDate DESC
    ]) {
      if (!waitlistBySession.containsKey(waitlisted.Course_Session__c)) {
        waitlistBySession.put(
          waitlisted.Course_Session__c,
          new List<Enrollment__c>()
        );
      }
      waitlistBySession.get(waitlisted.Course_Session__c).add(waitlisted);
    }

    List<Enrollment__c> toUpdate = new List<Enrollment__c>();

    for (Enrollment__c cancelled : cancelledEnrollments) {
      Course_Session__c session = sessions.get(cancelled.Course_Session__c);
      if (session == null) {
        continue;
      }

      Integer maxSeats = session.Max_Seats__c != null
        ? Integer.valueOf(session.Max_Seats__c)
        : 0;
      Integer confirmed = session.Confirmed_Enrollments__c != null
        ? Integer.valueOf(session.Confirmed_Enrollments__c)
        : 0;

      List<Enrollment__c> stack = waitlistBySession.get(session.Id);
      if (confirmed < maxSeats && stack != null && !stack.isEmpty()) {
        Enrollment__c next = stack.remove(0);
        next.Status__c = CONFIRMED;
        toUpdate.add(next);
      }
    }

    if (!toUpdate.isEmpty()) {
      update toUpdate;
    }
  }
}
