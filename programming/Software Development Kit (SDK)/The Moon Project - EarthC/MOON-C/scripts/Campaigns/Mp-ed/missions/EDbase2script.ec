mission "translateEDBase2"
{
    consts
    {
        accountResearchBase = 2;
    }

    player p_Player;
        player p_EnemyUCS;
        player p_EnemyLC;

        int i;

    state Initialize;
    state Nothing;

    state Initialize
    {
        unitex uHero;
        //----------- Goals ------------------
        
        //----------- Players ----------------
        p_Player = GetPlayer(2);
                p_EnemyUCS = GetPlayer(1);
                p_EnemyLC = GetPlayer(3);
        //----------- AI ---------------------

        
                p_EnemyUCS.EnableAIFeatures(aiEnabled,false);
                p_EnemyLC.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        p_Player.SetMoney(0);
                p_EnemyUCS.SetMoney(0);
                p_EnemyLC.SetMoney(0);
        
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,false);
                
                p_Player.EnableBuilding("EDBPP",true);
        p_Player.EnableBuilding("EDBBA",true);//JS 
        p_Player.EnableBuilding("EDBFA",false);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBAB",true);//JS 
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",false);
        p_Player.EnableBuilding("EDBMI",false);
        p_Player.EnableBuilding("EDBTC",false);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",true);
                p_Player.EnableBuilding("EDBBT",true);
                p_Player.EnableBuilding("EDBHT",true);
                p_Player.EnableBuilding("EDBART",false);
        // 4th tab
                p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",true);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",true);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",true);
                
                //----------- Research ---------------
                
                
                //--- Variables for campaign goals ---
                //p_Player.SetScriptData(0,0);
                //p_Player.SetScriptData(1,0);
                //p_Player.SetScriptData(2,0);
                //p_Player.SetScriptData(3,0);
                //p_Player.SetScriptData(4,0);

        //----------- Camera -----------------
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
            if(p_Player.GetScriptData(10))//Attack
            {
                AddBriefing("translateBriefingBase2a");
                p_Player.SetScriptData(10,0);
                p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX(),p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP1",null,null,null,0);                  
                p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+1,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP1",null,null,null,0);                  
                p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+2,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP1",null,null,null,0);                  
            }

            if(p_Player.GetScriptData(accountResearchBase))//Chash for accomplished mission
            {
                p_Player.AddMoney(p_Player.GetScriptData(accountResearchBase));
                p_Player.SetScriptData(accountResearchBase,0);
            }
            if(p_Player.GetScriptData(4))//Chash for secondary goals mission
            {
                p_Player.AddMoney(p_Player.GetScriptData(4));
                p_Player.SetScriptData(4,0);
            }

            return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------  
    //-----------------------------------------------------------------------------------------
    event CustomEvent0(int k1,int k2,int k3,int k4) 
    {
        if(k4==128)
        {
            EnableUnitSounds(false);
            EnableBuildingSounds(false);
        }
    }
}
