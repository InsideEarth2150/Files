mission "translateMissionEDBaseLC"
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
        
        //weapons
        p_PlayerLC.EnableResearch("RES_LC_WCH2",false);
        p_PlayerLC.EnableResearch("RES_LC_WSR2",false);
        p_PlayerLC.EnableResearch("RES_LC_WMR1",false);
        p_PlayerLC.EnableResearch("RES_LC_WSL1",false);
        p_PlayerLC.EnableResearch("RES_LC_WHL1",false);
        p_PlayerLC.EnableResearch("RES_LC_WSS1",false);
        p_PlayerLC.EnableResearch("RES_LC_WHS1",false);
        p_PlayerLC.EnableResearch("RES_LC_WARTILLERY",false);
        //CHASSIS
        p_PlayerLC.EnableResearch("RES_LC_UMO2",false);
        p_PlayerLC.EnableResearch("RES_LC_UCR1",false);
        p_PlayerLC.EnableResearch("RES_LC_UCU1",false);
        p_PlayerLC.EnableResearch("RES_LC_UME1",false);
        p_PlayerLC.EnableResearch("RES_LC_UBO1",false);
        //SPECIAL
        p_PlayerLC.EnableResearch("RES_LC_BMD",false);
        p_PlayerLC.EnableResearch("RES_LC_BHD",false);
        p_PlayerLC.EnableResearch("RES_LC_BWC",false);
        p_PlayerLC.EnableResearch("RES_LC_SGen",false);
        p_PlayerLC.EnableResearch("RES_LC_SHR1",false);
        p_PlayerLC.EnableResearch("RES_LC_REG1",false);
        p_PlayerLC.EnableResearch("RES_LC_SOB1",false);
        //AMMO
        p_PlayerLC.EnableResearch("RES_MCH2",false);
        p_PlayerLC.EnableResearch("RES_MSR2",false);
        p_PlayerLC.EnableResearch("RES_MMR2",false);
        return Nothing;
    }
    state Nothing
    {
    }
}