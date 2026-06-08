public abstract class AbstractTriggerHandler {
    private static Set<String> bypassedHandlers = new Set<String>();

    public static void bypassHandler(String handlerName) {
        bypassedHandlers.add(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return bypassedHandlers.contains(handlerName);
    }

    public static void clearBypass(String handlerName) {
        bypassedHandlers.remove(handlerName);
    }

    public abstract String getHandlerName();

    public virtual void beforeInsert(List<SObject> newList) {}
    public virtual void afterInsert(List<SObject> newList) {}
    public virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void beforeDelete(List<SObject> oldList) {}
    public virtual void afterDelete(List<SObject> oldList) {}

    public void run() {
        if (isBypassed(getHandlerName())) {
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    beforeInsert(Trigger.new);
                } else if (Trigger.isUpdate) {
                    beforeUpdate(Trigger.new, Trigger.oldMap);
                } else if (Trigger.isDelete) {
                    beforeDelete(Trigger.old);
                }
            } else {
                if (Trigger.isInsert) {
                    afterInsert(Trigger.new);
                } else if (Trigger.isUpdate) {
                    afterUpdate(Trigger.new, Trigger.oldMap);
                } else if (Trigger.isDelete) {
                    afterDelete(Trigger.old);
                }
            }
        }
    }
}