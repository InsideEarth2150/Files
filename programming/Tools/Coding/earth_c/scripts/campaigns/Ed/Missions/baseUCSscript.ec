mission "translateMissionEDBaseUCS"
{
    player p_PlayerUCS;
    
    state Initialize;
    state Nothing;
    state Initialize
    {
        p_PlayerUCS = GetPlayer(1);
        p_PlayerUCS.SetMoney(10000);
        
        p_PlayerUCS.EnableAIFeatures(aiBuildTanks,false);   
        p_PlayerUCS.EnableAIFeatures(aiBuildShips,false);
        p_PlayerUCS.EnableAIFeatures(aiBuildHelicopters,false);
        p_PlayerUCS.EnableAIFeatures(aiBuildSpecialUnits,false);
        
        //weapons
        p_PlayerUCS.EnableResearch("RES_UCS_WCH2",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WSR1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WASR1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WSG1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WHG1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WMR1",false);    
        p_PlayerUCS.EnableResearch("RES_UCS_WSP1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WHP1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WAPB1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_WSD",false);
        //CHASSIS
        p_PlayerUCS.EnableResearch("RES_UCS_UML1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_UHL1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_UBL1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_UMI1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_UBS1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_USM1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_UOH2",false);
        p_PlayerUCS.EnableResearch("RES_UCS_UAH1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_GARG1",false);
        p_PlayerUCS.EnableResearch("RES_UCS_BOMBER21",false);
        p_PlayerUCS.EnableResearch("RES_UCS_BOMBER31",false);
        //AMMO
        p_PlayerUCS.EnableResearch("RES_MCH2",false);
        p_PlayerUCS.EnableResearch("RES_MSR2",false);
        p_PlayerUCS.EnableResearch("RES_MMR2",false);
        p_PlayerUCS.EnableResearch("RES_UCS_MB2",false);
        p_PlayerUCS.EnableResearch("RES_UCS_MG2",false);
        //SPECIAL
        p_PlayerUCS.EnableResearch("RES_UCS_BMD",false);
        p_PlayerUCS.EnableResearch("RES_UCS_BHD",false);
        p_PlayerUCS.EnableResearch("RES_UCS_RepHand",false);
        p_PlayerUCS.EnableResearch("RES_UCS_SGen",false);
        p_PlayerUCS.EnableResearch("RES_UCS_SHD",false);
        
        return Nothing;
    }
    state Nothing
    {
    }
}