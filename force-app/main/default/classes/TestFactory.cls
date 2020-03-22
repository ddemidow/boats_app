@isTest
public with sharing class TestFactory 
{
    public static List<Mix__c> createMixes(Integer mixCount) 
    {
        List<Mix__c> mixList = new List<Mix__c>();
        for(Integer i = 0; i < mixCount; i++)
        {
            mixList.add(new Mix__c(Name = 'Mix ' + i));
        }
        return mixList;
    }

    public static List<Song__c> createSongs(Integer songCount)
    {
        List<Song__c> songList = new List<Song__c>();
        for(Integer i = 0; i < songCount; i++)
        {
            songList.add(new Song__c(
                                    Name = 'Song ' + i,  
                                    Artist__c = 'Artist ' + i, 
                                    Length_m__c = 3, Track_Count__c = 0, 
                                    Track_Licenses__c = 5));

            if(math.mod(i, 2) == 0)
            {
                songList[i].Genre__c = 'Pop';
            } else
            {
                songList[i].Genre__c = 'Rap';
            }
        }
        return songList;
    }

    public static List<Track__c> createTracks(List<Song__c> songList, Mix__c mix)
    {
        List<Track__c> trackList = new List<Track__c>();
        for(Song__c currentSong : songList)
        {
            trackList.add(new Track__c(Song__c = currentSong.Id, Mix__c = mix.Id));
        }     
        return trackList;
    }
}