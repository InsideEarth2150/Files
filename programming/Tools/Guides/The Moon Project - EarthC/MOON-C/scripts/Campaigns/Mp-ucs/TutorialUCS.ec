campaign "translateTutorialUCS"
{
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        CreateGamePlayer(1,raceUCS,playerLocal,null);
        CreateGamePlayer(2,raceED,playerAI,null);
        
        SetTime(100);
        RegisterMission(0,"!TutorialUCS","UCS\\Missions\\TutorialUCSmis","",0,0,0,0,0,0);
        LoadMission(0,0);
        SetAvailableWorlds(1);
        SetActivePlayerAndWorld(1,0);
        return Nothing;
    }
    state Nothing
    {
        return Nothing,200;
    }
    
}