campaign "translateCampaignTutorialED1"
{
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        CreateGamePlayer(1,raceUCS,playerAI,"TestGameAI");
        CreateGamePlayer(2,raceED,playerLocal,"TestGameAI");
        
        SetTime(100);
        RegisterMission(0,"!TutorialED1","ED\\Missions\\TutorialED1mis","",0,0,0,0,0,0);
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