campaign "translateTutorialLC"
{
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        CreateGamePlayer(1,raceUCS,playerAI,"TestGameAI");
        CreateGamePlayer(3,raceLC,playerLocal,"TestGameAI");
        
        RegisterMission(0,"!TutorialLC","LC\\Missions\\TutorialLCmis","",0,0,0,0,0,0);
        LoadMission(0,0);
        SetAvailableWorlds(1);
        SetActivePlayerAndWorld(3,0);
        SetTime(100);
        return Nothing;
    }
    state Nothing
    {
        return Nothing,200;
    }
    
}