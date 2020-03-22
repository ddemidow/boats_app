public with sharing class TrackTriggerHelper 
{
    public static void setGenres(List<Track__c> trackList) 
    {
        Set<Id> mixIds = new Set<Id>();

        for(Track__c currentTrack : trackList)
        {
            mixIds.add(currentTrack.Mix__c);
        }

        Map<Id, Mix__c> mixToUpdate = new Map<Id, Mix__c>();

        List<AggregateResult> aggregateResults = 
        [
            SELECT Mix__r.Id Id, Song__r.Genre__c songGenre, count(Id) 
            FROM Track__c 
            WHERE Mix__r.Id IN :mixIds
            GROUP BY Mix__r.Id, Song__r.Genre__c
            ORDER BY Mix__r.Id, count(Id) DESC
        ];

        for(AggregateResult currentAR : aggregateResults)
        {
            if(!mixToUpdate.containsKey((Id)currentAR.get('Id')))
            {
                mixToUpdate.put((Id)currentAR.get('Id'), new Mix__c(Id = (Id)currentAR.get('Id')));
            }
            if(mixToUpdate.get((Id)currentAR.get('Id')).Primary_Genre__c == null)
            {
                mixToUpdate.get((Id)currentAR.get('Id')).Primary_Genre__c = (String)currentAR.get('songGenre');
                continue;
            }
            else if(mixToUpdate.get((Id)currentAR.get('Id')).Secondary_Genre__c == null)
            {
                mixToUpdate.get((Id)currentAR.get('Id')).Secondary_Genre__c = (String)currentAR.get('songGenre');
                continue;
            }
            continue;    
        }
        
        if(!mixToUpdate.isEmpty())
        {
            update mixToUpdate.values();
        }
    }

    public static void setTrackCount(List<Track__c> trackList) 
    {
        List<Song__c> songsToUpdate = new List<Song__c>();

        Set<Id> songIds = new Set<Id>();

        for(Track__c currentTrack : trackList)
        {
            songIds.add(currentTrack.Song__c);
        }

        List<AggregateResult> aggregateResults = 
        [
            SELECT Song__r.Id songId, count(Id) trackCount 
            FROM Track__c 
            WHERE Song__r.Id IN :songIds 
            GROUP BY Song__r.Id
        ];
        
        for(AggregateResult currentAR : aggregateResults)
        {
            songsToUpdate.add(new Song__c(Id =(Id)currentAR.get('songId'), Track_Count__c = (Integer)currentAR.get('trackCount')));
        }

        if(!songsToUpdate.isEmpty())
        {
            update songsToUpdate;
        }
    }
}