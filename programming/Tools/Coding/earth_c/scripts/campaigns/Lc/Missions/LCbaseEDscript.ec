mission "translateMissionBaseED"
{
    player p_Player;
    
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        p_Player = GetPlayer(2);
        p_Player.SetMoney(25000);
        
        p_Player.EnableAIFeatures(aiBuildTanks,false);  
        p_Player.EnableAIFeatures(aiBuildShips,false);
        p_Player.EnableAIFeatures(aiBuildHelicopters,false);
        
        p_Player.EnableAIFeatures(aiBuildSpecialUnits,false);
        
        //weapons
        p_Player.EnableResearch("RES_ED_ACH2",false);
        p_Player.EnableResearch("RES_ED_WCA2",false);
        p_Player.EnableResearch("RES_ED_WHC1",false);
        p_Player.EnableResearch("RES_ED_WSR1",false);
        p_Player.EnableResearch("RES_ED_WMR1",false);
        p_Player.EnableResearch("RES_ED_AMR1",false);
        p_Player.EnableResearch("RES_ED_WHR1",false);
        p_Player.EnableResearch("RES_ED_WSL1",false);
        p_Player.EnableResearch("RES_ED_WHL1",false);
        p_Player.EnableResearch("RES_ED_WSI1",false);
        p_Player.EnableResearch("RES_ED_AB1",false);
        
        //ammo
        p_Player.EnableResearch("RES_MCH2",false);
        p_Player.EnableResearch("RES_ED_MSC2",false);
        
        //chassis
        p_Player.EnableResearch("RES_ED_UHT1",false);
        p_Player.EnableResearch("RES_ED_UBT1",false);
        p_Player.EnableResearch("RES_ED_UMI1",false);
        p_Player.EnableResearch("RES_ED_UHW1",false);
        
        p_Player.EnableResearch("RES_ED_UA11",false);
        p_Player.EnableResearch("RES_ED_UA21",false);
        p_Player.EnableResearch("RES_ED_UA31",false);
        p_Player.EnableResearch("RES_ED_UA41",false);
        //special
        p_Player.EnableResearch("RES_ED_SCR",false);
        p_Player.EnableResearch("RES_ED_SGen",false);
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        
        return Nothing,600;
    }
    
}