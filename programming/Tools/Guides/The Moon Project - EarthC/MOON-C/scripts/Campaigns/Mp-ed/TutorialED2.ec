campaign "translateCampaignTutorialED2"
{
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        CreateGamePlayer(1,raceUCS,playerAI,"TestGameAI");
        CreateGamePlayer(2,raceED,playerLocal,"TestGameAI");
        CreateGamePlayer(3,raceUCS,playerAI,"TestGameAI");
        CreateGamePlayer(4,raceUCS,playerAI,"TestGameAI");
        
        SetTime(100);
        RegisterMission(0,"!TutorialED2","ED\\Missions\\TutorialED2mis","",0,0,0,0,0,0);
        LoadMission(0,0);
        SetAvailableWorlds(1);
        SetActivePlayerAndWorld(2,0);
        return Nothing;
    }
    state Nothing
    {
        return Nothing,200;
    }
}