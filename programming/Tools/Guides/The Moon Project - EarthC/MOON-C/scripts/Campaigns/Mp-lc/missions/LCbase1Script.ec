mission "translateLCBase1"
{
    player p_Player;
    
    state Initialize;
    state Nothing;
    state EndGameState;

    state Initialize
    {
        p_Player=GetPlayer(3);
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(!p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateCampaignLCBaseDestroyed",p_Player.GetName());
            return EndGameState,5;
        }
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state EndGameState
    {
        EnableNextMission(0,2);//end campaign
        return EndGameState,600;
    }

}