trigger TrackTrigger on Track__c (after insert, after update, after delete)
{
    TriggerTemplate.TriggerManager triggerManager = new TriggerTemplate.TriggerManager();
    triggerManager.addHandler(
        new TrackHandler(), 
        new List<TriggerTemplate.TriggerAction>
        {
            TriggerTemplate.TriggerAction.afterInsert,
            TriggerTemplate.TriggerAction.afterUpdate,
            TriggerTemplate.TriggerAction.afterDelete
        }
    );
    triggerManager.runHandlers();
}