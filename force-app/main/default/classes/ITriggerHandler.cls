public interface ITriggerHandler {
    void beforeInsert(List<SObject> newList);
    void afterInsert(List<SObject> newList);
    void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap);
    void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap);
    void beforeDelete(List<SObject> oldList);
    void afterDelete(List<SObject> oldList);
}