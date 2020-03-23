public with sharing class MixBuilderController 
{
    // посмотри что из всех этих полей не используется напрямую на странице и помечай такие поля как transient, это ускорит работу страницы
    public Mix__c mix{public get; public set;} //public Mix__c mix {public get; public set;}
    public Map<Id,Song__c> selectedSongs = new Map<Id,Song__c>(); // не вижу смысла в этом поле, используешь его только в контролере, на странице его нет, пересмотри пожалуйста все
    																// филды на наличие подобных ситуаций
    private List<Song__c> genreList; //что-то с неймингом Song != Mix
    private List<Track__c> tracksInMix = new List<Track__c>();
    private List<Track__c> tracksToInsert = new List<Track__c>();
    private List<Track__c> tracksToDelete = new List<Track__c>();
    public String currentGenre {get; set;}
    private String currentMixId {get; set;}
    // такие разделения по использованию полей - это хорошо, но старайся все такие группы тоже чтруктурировать сначала private потом public (или наоборот)
    private Integer trackCount = 0;
    private static final Integer maxRemainingTracks = 20; // а константы в самом начале подсписка
    private Integer remainingTracks = 20;
    private Decimal mixLenght = 0;
    private static final Decimal maxRemainingLenght = 90;
    private Decimal remainingLenght = 90;
    public Id songId {get; set;}

    ///asdasdasd

    ApexPages.standardController m_sc = null; // нейминг хромает!

    public static final Integer QUERY_LIMIT = 10000; // круто!
    public static final Integer PAGE_SIZE = 5;

    String soql; // модификатор доступа

    public List <WrapperClass> wrapperRecordList; //
    public Map<Id, WrapperClass> mapHoldingSelectedRecords; //

    public MixBuilderController(ApexPages.StandardController stdController) //не жалей букв можно назвать standardController
    {
        m_sc = stdController;

        currentMixId = ApexPages.currentPage().getParameters().get('id');
        
        if (currentMixId == null)
        {
           mix = new Mix__c(); 
           mapHoldingSelectedRecords = new Map<Id, WrapperClass>();
        } 
        else 
        {
            mix = [SELECT Id, Name, Customer__c FROM Mix__c WHERE Id = :currentMixId]; // запрос не отформатирован
            //new line
            mapHoldingSelectedRecords = new Map<Id, WrapperClass>(); // если инитишь мапку в любом случае, почему бы не вынести это из if-else?
            // new line
            tracksInMix = [SELECT Id, Song__c, Mix__c FROM Track__c WHERE Mix__c = :currentMixId]; // запрос не отформатирован

            for (Song__c song : [SELECT Id, Name, Genre__c, Length_m__c FROM Song__c]) // зачем селектить все? проще же собрать айдишьки с треков и селектнуть только нужные песни
            {                                                                          // запросы без фильтров ПОЧТИ ВСЕГДА плохо!
                selectedSongs.put(song.Id, song);
            }
            // new line
            for (Track__C track : tracksInMix)
            {
                mapHoldingSelectedRecords.put(track.Song__c, new WrapperClass(selectedSongs.get(track.Song__c), true));
            }

            for (WrapperClass selectedItem : mapHoldingSelectedRecords.values()) 
            {
                mixLenght += selectedItem.song.Length_m__c;
            }
            // new line
            trackCount = mapHoldingSelectedRecords.size();
            remainingTracks = maxRemainingTracks - trackCount;
            remainingLenght = maxRemainingLenght - mixLenght;
        }  
    }

    public ApexPages.StandardSetController setCon
    {
        get 
        {
            soql = ' SELECT Id, Name, Genre__c, Length_m__c FROM Song__c ';

            if(currentGenre != null && currentGenre != '--Any Genre--') //--Any Genre-- лучше в константу класса перенести
            {
                soql += ' WHERE Genre__c = :currentGenre ';
            }
            soql += ' ORDER BY Name LIMIT :QUERY_LIMIT '; // ок но посмотри ещё escapeSingleQuotes метод класса стринг

            if (setCon == null)
            {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                setCon.setPageSize(PAGE_SIZE); // тут класс
            }

            return setCon;
        }
        // new line
        set;
    }

    public class WrapperClass
    {
        public Song__c song {get; set;}
        public Boolean isSelected {get; set;}

        public WrapperClass(Song__c song, Boolean isSelected)
        {
            this.song = song;
            this.isSelected = isSelected;
        }
    }
    
    public void resetSetCon() //cool
    {
        setCon = null;
    }

    public void countSummary()
    {
        for (WrapperClass wrp : wrapperRecordList)
        {
            if (wrp.isSelected && !mapHoldingSelectedRecords.containsKey(wrp.song.id))
            {
                mapHoldingSelectedRecords.put(wrp.song.id, wrp);
            }
        }

        if (mapHoldingSelectedRecords != null)
        {
            if (mapHoldingSelectedRecords.get(songId).isSelected)
            {
                mixLenght += mapHoldingSelectedRecords.get(songId).song.Length_m__c;          
            }
            else 
            {
                mixLenght -= mapHoldingSelectedRecords.get(songId).song.Length_m__c;
                mapHoldingSelectedRecords.remove(songId);    
            }
            trackCount = mapHoldingSelectedRecords.size();
            remainingTracks = maxRemainingTracks - trackCount;
            remainingLenght = maxRemainingLenght - mixLenght;   
        }
    }

    public List<SelectOption> getGenres()
    {
        List<SelectOption> options = new List<SelectOption>();

        // операции с схемой очень ресурсоемкие поэтому не делай их в цикле, тут все ок просто, FYI
        Schema.DescribeFieldResult fieldResult = Song__c.Genre__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        options.add(new SelectOption('--Any Genre--', '--Any Genre--')); //global constants!
        // new line
        for (Schema.PicklistEntry fr : ple)//fr плохое название, делай везде название по шаблону current+ObjectName
        {
            options.add(new SelectOption(fr.getLabel(), fr.getValue()));
        }

        return options;
    }

    public List <WrapperClass> getWrapperRecordList()
    {
        //  я так понимаю эта логика завязываеться на то что ты обнуляешь standard set controller, тогда сделай хотябы проверку if (setCon = null), постоянно делать new wrapper list 
		//  в геттере не есть хорошо
        wrapperRecordList = new List<WrapperClass>();
        // new line
        for (Song__c song : (List<Song__c>)setCon.getRecords())
        {
            if (mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(song.id))
            {
                 wrapperRecordList.add(mapHoldingSelectedRecords.get(song.id));    
            }
            else
            {
                 wrapperRecordList.add(new WrapperClass(song, false));    
            }
        }

        return wrapperRecordList;
    }

    // просто public set; не нужно лишнего кода
    public void setWrapperRecordList(List <WrapperClass> wrapperRecordList)
    {
        this.wrapperRecordList = wrapperRecordList;
    } 

    // тоже самое
    public Map<Id, WrapperClass> getMapHoldingSelectedRecords()
    {
        return mapHoldingSelectedRecords;
    }

    // тоже самое
    public void setMapHoldingSelectedRecords(Map<Id, WrapperClass> mapHoldingSelectedRecords)
    {
        this.mapHoldingSelectedRecords = mapHoldingSelectedRecords;
    }

    // тоже самое
    public Integer getTrackCount()
    {
        return trackCount;
    }
	// тоже самое
    public void setTrackCount(Integer trackCount)
    {
        this.trackCount = trackCount;
    }    

    // тоже самое
    public Integer getRemainingTracks()
    {
        return remainingTracks;
    }

    // тоже самое
    public void setRemainingTracks(Integer remainingTracks)
    {
        this.remainingTracks = remainingTracks;
    }  
    
    // тоже самое
    public Decimal getMixLenght()
    {
        return mixLenght;
    }

    // тоже самое
    public void setMixLenght(Decimal mixLenght)
    {
        this.mixLenght = mixLenght;
    }

    // тоже самое
    public Decimal getRemainingLenght()
    {
        return remainingLenght;
    }

    // тоже самое
    public void setRemainingLenght(Decimal remainingLenght)
    {
        this.remainingLenght = remainingLenght;
    }

    // тоже самое
    public Map<Id,Song__c> getSelectedSongs()
    {
        return selectedSongs;
    }

    // тоже самое
    public void setSelectedSongs(Map<Id,Song__c> selectedSongs)
    {
        this.selectedSongs = selectedSongs;
    }

    // делается через standartController.hasNext
    public Boolean hasNext 
    {
        get
        {
          return setCon.getHasNext();
        }
        set;
    }

    // делается через standartController.hasPrevious
    public Boolean hasPrevious 
    {
        get 
        {
          return setCon.getHasPrevious();
        }
        set;
    }

    // standartController.pageNumber
    public Integer pageNumber
    {
        get 
        {
          return setCon.getPageNumber();
        }
        set;
    }

    Public Integer getTotalPages()
    {
        // чего так сложно то?) мне кажется можно было обычным делением обойтись + 1 если остаток не 0
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    public PageReference save() 
    {
        Savepoint sp = Database.setSavePoint();

        upsert mix;

        if (tracksInMix.size() > 0)
        {
            for (Track__c currentTrack : tracksInMix)
            {
                // опять таки почему тут имеет смысл SavePoint, ты подтягиваешь текущее состояние микса с его выброными треками при инициализации страницы, то есть если в пока ты 
                // будешь менять микс на своей странице, кто-то поменяет его извне, страница этого не узнает и попробует удалить уже удалённый миккс например. Поэтому вообще был бы 
				// смысл переподтянуть актуально состояние тут. !FYI! !NO CHANGES NEEDED!
                if (!mapHoldingSelectedRecords.containsKey(currentTrack.Song__c))
                {
                    tracksToDelete.add(currentTrack);
                    mapHoldingSelectedRecords.remove(currentTrack.Song__c);
                }
                else
                {
                    mapHoldingSelectedRecords.remove(currentTrack.Song__c);
                }
            }

            if (tracksToDelete.size() > 0)
            {
                Database.DeleteResult[] drList = Database.delete(tracksToDelete, false);

                for (Database.DeleteResult dr : drList)
                {
                    if (!dr.isSuccess())
                    {
                        Database.rollback(sp);
                        break;
                    }   
                } 
            }
        } 

        for (WrapperClass wr : mapHoldingSelectedRecords.values()) 
        {
            tracksToInsert.add(new Track__c(Song__c = wr.song.id, Mix__c = mix.id));
        }

        if (tracksToInsert.size() > 0)
        {
            Database.SaveResult[] irList = Database.insert(tracksToInsert, false);
            for (Database.SaveResult ir : irList)
            {
                if (!ir.isSuccess())
                {
                    Database.rollback(sp);
                    break;
                }   
            }
        }
        
        // хотелось бы также увидеть отпраку сообщения об ошибке на страницу
        
        PageReference mixPage = new ApexPages.StandardController(mix).view();
        mixPage.setRedirect(true);
        return mixPage;
    }

    public Pagereference doCancel()
    {
        return m_sc.cancel();
    }
}