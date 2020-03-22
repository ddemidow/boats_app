public with sharing class TrackHandler implements TriggerTemplate.Handler 
{
    private List<Track__c> newValues;
    private Map<Id, Track__c> oldValues;

    public void setValues(List<sObject> newValues, Map<Id, sObject> oldValues)
    {
        this.newValues = newValues;
        this.oldValues = (Map<Id, Track__c>) oldValues;
    }

    public void handle(TriggerTemplate.TriggerAction action)
    {
        if ((action == TriggerTemplate.TriggerAction.afterInsert) || (action == TriggerTemplate.TriggerAction.afterUpdate))
        {
            TrackTriggerHelper.setGenres(this.newValues);
            TrackTriggerHelper.setTrackCount(this.newValues);
        }
        else if ((action == TriggerTemplate.TriggerAction.afterDelete)) 
        {
            TrackTriggerHelper.setGenres(this.oldValues.values());
            TrackTriggerHelper.setTrackCount(this.oldValues.values());
        }
    }
}