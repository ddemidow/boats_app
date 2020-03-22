@isTest
private class TrackTriggerTest 
{
    @TestSetup
    static void makeData()
    {
        List<Song__c> songs = TestFactory.createSongs(20);
        List<Mix__c> mixes = TestFactory.createMixes(5);
        List<Track__c> tracks = new List<Track__c>();

        insert mixes;
        insert songs;

        TestFactory.createTracks(songs, mixes[0]);
        TestFactory.createTracks(songs, mixes[1]);

        insert tracks;
    }


    @isTest
    static void testBulkInsert() 
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c];
        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 10];
        List<Track__c> newTracks = TestFactory.createTracks(songs, mixes[2]);

        Test.startTest();
        insert newTracks;
        Test.stopTest();
    }

    @isTest
    static void testBulkUpdate()
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c OFFSET 3];
        List<Track__c> tracksToUpdate = [SELECT Id FROM Track__c LIMIT 10];
        for(Track__c currentTrack : tracksToUpdate)
        {
            currentTrack.Mix__c = mixes[0].Id;
        }

        Test.startTest();
        update tracksToUpdate;
        Test.stopTest();
    }

    @isTest
    static void testBulkDelete()
    {
        List<Track__c> tracks = [SELECT Id 
                                FROM Track__c 
                                WHERE Song__r.Genre__c = 'Rap' 
                                LIMIT 10];

        Test.startTest();
        delete tracks;
        Test.stopTest();     
    }
}