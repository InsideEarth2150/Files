mission "translateLCBase2"
{
    consts
    {
        scriptFieldMoney=9;
    }

    player p_Enemy;
    player p_Player;
    
    state Initialize;
    state Nothing;
    state EndGameState;

    state Initialize
    {
        p_Player = GetPlayer(3);
        p_Enemy = GetPlayer(1);
        p_Enemy.SetMoney(10000);
        
        p_Enemy.EnableAIFeatures(aiBuildTanks,false);   
        p_Enemy.EnableAIFeatures(aiBuildShips,false);
        p_Enemy.EnableAIFeatures(aiBuildHelicopters,false);
        p_Enemy.EnableAIFeatures(aiBuildSpecialUnits,false);
        
        p_Enemy.EnableResearch("RES_UCS_WMR1",false);   //615
        p_Enemy.EnableResearch("RES_UCS_WAMR1",false);  //615
        p_Enemy.EnableResearch("RES_UCS_WHP1",false);   //615
        p_Enemy.EnableResearch("RES_UCS_UHL1",false);   //615
        p_Enemy.EnableResearch("RES_UCS_BOMBER21",false);   //615
        p_Enemy.EnableResearch("RES_UCS_BOMBER31",false);   //615

        p_Enemy.EnableResearch("RES_UCS_UBL1",false);   //617

        p_Enemy.EnableResearch("RES_UCS_WAPB1", true);//618
        p_Enemy.EnableResearch("RES_UCS_MB2", true);//618

        p_Enemy.EnableResearch("RES_UCS_UMI1",false);   //Miner
        p_Enemy.EnableResearch("RES_UCS_USS1", false);  //Shark
        p_Enemy.EnableResearch("RES_UCS_UBS1", false);  //Hydra
        p_Enemy.EnableResearch("RES_UCSUUT", false);    //Unit Transporter
        p_Enemy.EnableResearch("RES_UCS_PC",false); //Stacjonarne dzia³o plazmowe
        p_Enemy.EnableResearch("RES_UCS_WSD",false);    //Laser antyrakietowy

        p_Player.EnableBuilding("LCBRC",false); 

        return Nothing;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(p_Player.GetScriptData(scriptFieldMoney))//Chash from missions after the end. 
        {
            p_Player.AddMoney(p_Player.GetScriptData(scriptFieldMoney));
            p_Player.SetScriptData(scriptFieldMoney,0);
        }

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