mission "translateMissionUCSBaseLCMP01"
{
    player p_PlayerLC;
    
    state Initialize;
    state Nothing;

    state Initialize
    {
        p_PlayerLC=GetPlayer(3);
        p_PlayerLC.SetMoney(10000);
        p_PlayerLC.EnableAIFeatures(aiBuildTanks,false);    
        p_PlayerLC.EnableAIFeatures(aiBuildShips,false);
        p_PlayerLC.EnableAIFeatures(aiBuildHelicopters,false);
        p_PlayerLC.EnableAIFeatures(aiBuildSpecialUnits,false);
        EnableUnitSounds(false);
        EnableBuildingSounds(false);

        return Nothing;
    }
    state Nothing
    {
    }
    event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
        if(k1==1)
        {
            EnableUnitSounds(true);
            EnableBuildingSounds(true);
        }
    }

}






