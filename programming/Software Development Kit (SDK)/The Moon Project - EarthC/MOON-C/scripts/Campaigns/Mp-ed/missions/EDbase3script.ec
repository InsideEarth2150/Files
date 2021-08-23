mission "translateEDBase3"
{
    player p_Player;
        player p_EnemyUCS;
        player p_EnemyLC;

        int i;

    state Initialize;
    state Nothing;
        state Attack1;

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
        p_Player.EnableBuilding("EDBPP",true);//JS 
        p_Player.EnableBuilding("EDBBA",true);//JS 
        p_Player.EnableBuilding("EDBFA",false);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBAB",true);//JS 
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",false);
        p_Player.EnableBuilding("EDBMI",false);
        p_Player.EnableBuilding("EDBTC",false);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",true);//JS 
        p_Player.EnableBuilding("EDBBT",true);//JS 
        p_Player.EnableBuilding("EDBHT",true);//JS 
        p_Player.EnableBuilding("EDBART",false);
        // 4th tab
        p_Player.EnableBuilding("EDBUC",true);//JS
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",true);//JS 
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",true);//JS 
                
        //----------- Timers ---------------
        SetTimer(0,20*60*3);
        //----------- Camera -----------------
                p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        SetConsoleText("translateRecycleMessage",50);
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Attack1
    {
        AddBriefing(" ",p_Player.GetName());//help atak na centrum wynalazków
        return Nothing,50;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
            return Nothing,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        int nPrecent;

        nPrecent = Rand(60)+20;
        p_Player.SetDefaultUnitsRecyclePercent(nPrecent);
        SetConsoleText("translateRecycleMessage",nPrecent);
    }
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
