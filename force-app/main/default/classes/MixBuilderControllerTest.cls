@isTest
private class MixBuilderControllerTest 
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
    static void testMixInsert()
    {
        List<Song__c> songs = [SELECT Id, Name, Genre__c, Length_m__c FROM Song__c];
        Mix__c mix = new Mix__c();
        List<Track__c> tracksToInsert = new List<Track__c>();

        Track__c newTrack = new Track__c();
        tracksToInsert.add(newTrack);

        Test.startTest();

        PageReference pageRef = Page.MixBuilder;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(mix);
        MixBuilderController extension = new MixBuilderController(sc);
        extension.resetSetCon();
        extension.getWrapperRecordList();
        extension.getMapHoldingSelectedRecords();
        extension.getGenres();
        extension.save();
        extension.doCancel();
      
        Test.stopTest();
    }

    @isTest
    static void testMixUpdate()
    {
        List<Song__c> songs = [SELECT Id, Name, Genre__c, Length_m__c FROM Song__c]; 
        List<Mix__c> mix = [SELECT Id, Name, Customer__c FROM Mix__c];
        List<Track__c> tracksInMix = [SELECT Id, Song__c, Mix__c FROM Track__c WHERE Mix__c = :mix[0].Id];
        List<Track__c> tracksToInsert = new List<Track__c>();
        List<Track__c> tracksToDelete = [SELECT Id FROM Track__c];

        Track__c newTrack = new Track__c();
        tracksToInsert.add(newTrack);
        // tracksToDelete.remove[0];

        
        
        Test.startTest();

        PageReference pageRef = Page.MixBuilder;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('id', (String)mix[0].id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(mix[0]);
        MixBuilderController extension = new MixBuilderController(sc);

        extension.getWrapperRecordList();
        extension.getMapHoldingSelectedRecords();
        extension.getGenres();
        extension.save();
        extension.doCancel();

        Test.stopTest();
    }

}