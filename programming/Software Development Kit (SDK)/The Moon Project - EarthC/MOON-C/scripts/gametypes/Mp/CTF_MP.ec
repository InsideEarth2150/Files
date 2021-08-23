mission "translateGameTypeCTFMP"
{
    int nCashRate;
    int m_nD;
    
    enum comboCTFType
    {
        "translateScriptCTFTypeCapturedDies",
        "translateScriptCTFTypeCaptureAll",
multi:
        "translateScriptCTFType"
    }
    
    enum comboCashType
    {
        "translateScriptMineForMoney",
        "translateScript2500CRmin",
        "translateScript5000CRmin",
        "translateScript10000CRmin",
        "translateScript20000CRmin",
multi:
        "translateScriptGainingMoney"
    }

    enum comboResearchTime
    {
        "translateScriptNormalTime",
        "translateScript2xfaster",
        "translateScript4xfaster",
        "translateScript8xfaster",
multi:
        "translateScriptResearchTime"
    }

    enum comboResearchLimit
    {
        "translateScriptAllResearches",
        "translateScriptNoBombs",
        "translateScriptNoMassDestructionWeapons",
        "translateScriptNoBombsAndMDW",
multi:
        "translateScriptAvailableResearches"
    }

    enum comboUnitsLimit
    {
        "translateGameMenuUnitsLimitNoLimit",
        "translateGameMenuUnitsLimit10000CR",
        "translateGameMenuUnitsLimit20000CR",
        "translateGameMenuUnitsLimit30000CR",
        "translateGameMenuUnitsLimit50000CR",
multi:
        "translateGameMenuUnitsLimit"
    }

    enum comboAlliedVictory
    {
        "translateGameMenuAlliedVictoryNo",
        "translateGameMenuAlliedVictoryYes",
multi:
        "translateGameMenuAlliedVictory"
    }

    //sprawdza czy rPlayer ma flage w swojej bazie
    function int HaveFlagInBase(player rPlayer)
    {
        unitex flagEx;

        flagEx = rPlayer.GetScriptUnit(0);
        if ((flagEx != null) && flagEx.IsLive() && !flagEx.IsTransported() &&
            (Distance(flagEx.GetLocationX(), flagEx.GetLocationY(), rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY()) <= m_nD) &&
            (flagEx.GetLocationZ() == 0))
        {
            return true;
        }
        return false;
    }

    //sprawdza czy rPlayer i ew. jego przyjaciele maja zcapturowane wszystkie obce flagi
    function int HaveAllFlagsCapturedByAllies(player rPlayer)
    {
        int i;
        int j;
        player rAlly;
        player rEnemy;
        unitex flagExAlly;
        unitex flagExEnemy;
        int bCapturedEnemy;

        //najpierw sprawdzamy czy my i wszyscy nasi sprzymiezency maja flagi w bazach
        for (j=0;j<15;j=j+1)
        {
            rAlly = GetPlayer(j);
            if ((rAlly != null) && rAlly.IsAlive() && ((rAlly == rPlayer) || rPlayer.IsAlly(rAlly)))
            {
                if (!HaveFlagInBase(rAlly))
                {
                    return false;
                }
            }
        }
        for (i=0;i<15;i=i+1)
        {
            rEnemy = GetPlayer(i);
            if ((rEnemy != null) && (rEnemy != rPlayer) && !rPlayer.IsAlly(rEnemy))
            {
                flagExEnemy = rEnemy.GetScriptUnit(0);
                bCapturedEnemy = false;
                if ((flagExEnemy == null) || !flagExEnemy.IsLive() || flagExEnemy.IsTransported())
                {
                    return false;
                }
                for (j=0;j<15;j=j+1)
                {
                    rAlly = GetPlayer(j);
                    if ((rAlly != null) && rAlly.IsAlive() && ((rAlly == rPlayer) || rPlayer.IsAlly(rAlly)))
                    {
                        //HaveFlagInBase(rAlly) spelnione
                        flagExAlly = rAlly.GetScriptUnit(0);
                        if ((Distance(flagExEnemy.GetLocationX(), flagExEnemy.GetLocationY(), flagExAlly.GetLocationX(), flagExAlly.GetLocationY()) <= m_nD) &&
                            (flagExEnemy.GetLocationZ() == flagExAlly.GetLocationZ()))
                        {
                            bCapturedEnemy = true;
                        }
                    }
                }
                if (!bCapturedEnemy)
                {
                    return false;
                }
            }
        }
        return true;
    }

    state Initialize;
    state DelayedCommands;
    state Nothing;
    
    state Initialize
    {
        player rPlayer;
        int i;
        int nPlayers;
        unitex flagEx;
        
        
        if(comboCashType==0) nCashRate = 0;
        if(comboCashType==1) nCashRate = 2500;
        if(comboCashType==2) nCashRate = 5000;
        if(comboCashType==3) nCashRate = 10000;
        if(comboCashType==4) nCashRate = 20000;
        
        if(comboResearchTime==1) SetTimeDivider(2);
        if(comboResearchTime==2) SetTimeDivider(4);
        if(comboResearchTime==3) SetTimeDivider(8);

        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if (rPlayer!=null)
            {               
                if(rPlayer.GetRace()==raceUCS)
                {
                    rPlayer.EnableBuilding("UCSBLZ", false);
                    rPlayer.EnableBuilding("UCSBTB", false);
                }
                if(rPlayer.GetRace()==raceED)
                {
                    rPlayer.EnableBuilding("EDBLZ", false);
                    rPlayer.EnableBuilding("EDBTC", false);
                }
                if(rPlayer.GetRace()==raceLC)
                {
                    rPlayer.EnableBuilding("LCBLZ", false);
                    rPlayer.EnableBuilding("LCBSR", false);
                }
            }
        }
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            
            if(rPlayer!=null) 
            {
                rPlayer.SetMaxDistance(30);
                rPlayer.EnableCommand(commandSoldBuilding,true);
                rPlayer.AddResearch("RES_MISSION_PACK1_ONLY");

                if(comboCashType>0)
                {
                    rPlayer.EnableAIFeatures(aiBuildMiningBuildings|aiBuildMiningUnits|aiControlMiningUnits,false);
                    
                    rPlayer.EnableBuilding("EDBMI",false);
                    rPlayer.EnableBuilding("EDBRE",false);
                    rPlayer.EnableBuilding("UCSBRF",false);
                    rPlayer.EnableBuilding("LCBMR",false);
                    
                    rPlayer.EnableResearch("RES_UCS_UOH2",false);
                    rPlayer.EnableResearch("RES_UCS_UOH3",false);
                    rPlayer.EnableResearch("RES_UCS_UAH1",false);
                    rPlayer.EnableResearch("RES_UCS_UAH2",false);
                    rPlayer.EnableResearch("RES_UCS_UAH3",false);
                }

                if(comboResearchLimit==1||comboResearchLimit==3)
                {
                    //no bombs
                    rPlayer.EnableResearch("RES_ED_AB1",false);
                    rPlayer.EnableResearch("RES_ED_MB2",false);
                    rPlayer.EnableResearch("RES_UCS_WAPB1",false);
                    rPlayer.EnableResearch("RES_UCS_MB2",false);
                    //Moon Project                
                    rPlayer.EnableResearch("RES_UCS_ART",false);
                    rPlayer.EnableResearch("RES_ED_ART",false);
                    rPlayer.EnableResearch("RES_LC_ART",false);
                }
                if(comboResearchLimit==2||comboResearchLimit==3)
                {
                    //no UW
                    rPlayer.EnableResearch("RES_ED_WHR1",false);
                    rPlayer.EnableResearch("RES_LC_BWC",false);
                    rPlayer.EnableResearch("RES_LC_SDIDEF",false);
                    rPlayer.EnableResearch("RES_UCS_PC",false);
                    rPlayer.EnableResearch("RES_UCS_WSD",false);
                    //Moon project
                    rPlayer.EnableResearch("RES_UCS_USM1",false);
                    rPlayer.EnableResearch("RES_UCS_USM2",false);
                    rPlayer.EnableResearch("RES_ED_USM1",false);
                    rPlayer.EnableResearch("RES_ED_USM2",false);
                }

                if(comboAlliedVictory)
                    rPlayer.EnableAIFeatures2(ai2BNSendResult,false);//nie wysylac rezultatow do EARTH NETu       
                
                if(comboUnitsLimit==0) rPlayer.EnableMilitaryUnitsLimit(false);
                if(comboUnitsLimit==1) rPlayer.SetMilitaryUnitsLimit(10000);
                if(comboUnitsLimit==2) rPlayer.SetMilitaryUnitsLimit(20000);
                if(comboUnitsLimit==3) rPlayer.SetMilitaryUnitsLimit(30000);
                if(comboUnitsLimit==4) rPlayer.SetMilitaryUnitsLimit(50000);
                
                rPlayer.SetMoney(30000);
                
                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    rPlayer.CreateDefaultUnit(rPlayer.GetStartingPointX()+1,rPlayer.GetStartingPointY()+1,0);
                
                if(rPlayer.GetRace()==1)
                    flagEx = rPlayer.CreateUnitEx(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(), 0,"AI\\CivilEmpty","UCSUCTF",null,null,null,null);
                if(rPlayer.GetRace()==2)
                    flagEx = rPlayer.CreateUnitEx(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(), 0,"AI\\CivilEmpty","EDUCTF",null,null,null,null);
                if(rPlayer.GetRace()==3)
                    flagEx = rPlayer.CreateUnitEx(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(), 0,"AI\\CivilEmpty","LCUCTF",null,null,null,null);
                rPlayer.SetScriptUnit(0, flagEx, true);
                rPlayer.AddUnitToSpecialTab(flagEx, true, 0);
                rPlayer.SetScriptData(0, 1);//jesli 1 to flaga zmartwychwstaje niezaleznie od tego czy player zyje
                //zaznaczenie miejsca gdzie lezy flaga
                //CreateArtefact("NEASPECIAL2",rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),0,0,artefactSpecialAIOther,0);
                CreateArtefact("NEASPECIAL3",rPlayer.GetStartingPointX()+1,rPlayer.GetStartingPointY(),0,0,artefactSpecialAIOther,i);
                CreateArtefact("NEASPECIAL3",rPlayer.GetStartingPointX()-1,rPlayer.GetStartingPointY(),0,0,artefactSpecialAIOther,i);
                CreateArtefact("NEASPECIAL3",rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY()+1,0,0,artefactSpecialAIOther,i);
                CreateArtefact("NEASPECIAL3",rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY()-1,0,0,artefactSpecialAIOther,i);
            }
        }
        //policzenie ilu jest playerow (potrzebne do obliczenia odleglosci flag)
        nPlayers = 0;
        for(i=0;i<15;i=i+1)
        {
            if (GetPlayer(i))
            {
                nPlayers = nPlayers + 1;
            }
        }
        if (nPlayers <= 9) m_nD = 1;
        else m_nD = 3;
        SetTimer(0,300);
        SetTimer(1,1200);
        SetTimer(2,1);
        SetTimer(3,200);
        SetTimer(4,200);
        SetTimer(5,200);
        
        return DelayedCommands,20;
    }
    state DelayedCommands
    {
        int i;
        player rPlayer;

        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            
            if(rPlayer!=null) 
            {
                rPlayer.EnableAIFeatures2(ai2CaptureSpecialTarget,true);
            }
        }
        return Nothing;
    }
    state Nothing
    {
        return Nothing;
    }
    
    event RemoveResources()
    {
        if(comboCashType==0)
            false;
        else
            true;
    }
    
    event RemoveUnits()
    {
        true;
    }
    
    event Timer0()
    {
        int i;
        int j;
        int iCountBuilding;
        player rPlayer;
        player rAlly;
        int bHaveAlly;
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive())
            {
                iCountBuilding = rPlayer.GetNumberOfBuildings() + rPlayer.GetNumberOfUnits();
                if (iCountBuilding<=1)//1 bo flaga jest unitem
                {
                    //jesli to jest tryb 1 (capture all to win) i ten gracz ma jakichs przyjaciol to nie dajemy mu defeat
                    //(po to zeby ktos mogl mu przekazac buildera lub unity)
                    bHaveAlly = false;
                    if (comboCTFType == 1)
                    {
                        for (j=0;j<15;j=j+1)
                        {
                            rAlly = GetPlayer(j);
                            if ((rAlly != null) && (rAlly != rPlayer) && rAlly.IsAlive() && rPlayer.IsAlly(rAlly))
                            {
                                bHaveAlly = true;
                            }
                        }
                    }
                    if (!bHaveAlly)
                    {
                        rPlayer.Defeat();
                    }
                    //nie ma SetScriptData
                }
            }
        }
    }

    event Timer1()
    {
        int i;
        player rPlayer;
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                if(rPlayer.GetMoney()<100000)
                   rPlayer.AddMoney(nCashRate);
            }
        }
    }

    event Timer2()
    {
        int i;
        player rPlayer;
        unitex flagEx;
        int flagX;
        int flagY;
        int flagZ;

        //sprawdzenie zabicia flag - ew. utworzenie ich od nowa w ostatnim miejscu ich pobytu
        for (i=0;i<15;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if ((rPlayer!=null) && (rPlayer.GetScriptData(0) == 1))
            {
                flagEx = rPlayer.GetScriptUnit(0);
                if ((flagEx == null) || !flagEx.IsLive())
                {
                    if (flagEx == null)
                    {
                        flagX = rPlayer.GetScriptData(5);
                        flagY = rPlayer.GetScriptData(6);
                        flagZ = rPlayer.GetScriptData(7);
                    }
                    else
                    {
                        flagX = flagEx.GetLocationX();
                        flagY = flagEx.GetLocationY();
                        flagZ = flagEx.GetLocationZ();
                        rPlayer.AddUnitToSpecialTab(flagEx, false, -1);//wyrzucenie z taba
                    }
                    //tworzymy nowa flage
                    if(rPlayer.GetRace()==1)
                        flagEx = rPlayer.CreateUnitEx(flagX, flagY, flagZ,"AI\\CivilEmpty","UCSUCTF",null,null,null,null);
                    if(rPlayer.GetRace()==2)
                        flagEx = rPlayer.CreateUnitEx(flagX, flagY, flagZ,"AI\\CivilEmpty","EDUCTF",null,null,null,null);
                    if(rPlayer.GetRace()==3)
                        flagEx = rPlayer.CreateUnitEx(flagX, flagY, flagZ,"AI\\CivilEmpty","LCUCTF",null,null,null,null);
                    rPlayer.SetScriptUnit(0, flagEx, true);
                    rPlayer.AddUnitToSpecialTab(flagEx, true, 0);
                }
                else
                {
                    flagEx.RegenerateHP();
                    flagEx.RegenerateElectronics();
                    rPlayer.SetScriptData(5, flagEx.GetLocationX());
                    rPlayer.SetScriptData(6, flagEx.GetLocationY());
                    rPlayer.SetScriptData(7, flagEx.GetLocationZ());
                }
            }
        }
    }

    event Timer3()
    {
        int i;
        int j;
        int k;
        player rPlayer;
        player rEnemy;
        unitex flagEx;
        unitex flagExEnemy;
        int iAlivePlayers;
        int iCountBuilding;
        int bActiveEnemies;
        int bOneHasBeenDestroyed;   
        player rPlayer2;
        player rLastPlayer;
        int bIsVictoryAlliance;
        int bHaveSomeEnemy;


        if (comboCTFType == 0)
        {//captured flag defeats
            //sprawdzenie czy jakas flaga stoi w poblizu wrogiej flagi ktora stoi w poblizu swojego punktu startowego
            for (i=0; i<15; i=i+1)
            {
                rPlayer = GetPlayer(i);
                //nie sprawdzamy IsAlive bo ktos moze nie byc zywy ale jego flaga nie zostala jeszcze zcapturowana
                if (rPlayer!=null && rPlayer.IsAlive())
                {
                    flagEx = rPlayer.GetScriptUnit(0);
                    if ((flagEx != null) && !flagEx.IsTransported())
                    {
                        for (j=0; j<15; j=j+1)
                        {
                            rEnemy = GetPlayer(j);
                            if ((j!=i) && (rEnemy!=null) && rEnemy.IsAlive() && !rPlayer.IsAlly(rEnemy))
                            {
                                flagExEnemy = rEnemy.GetScriptUnit(0);
                                if ((flagExEnemy != null) && !flagExEnemy.IsTransported())
                                {
                                    if (HaveFlagInBase(rEnemy) &&
                                        (Distance(flagEx.GetLocationX(), flagEx.GetLocationY(), flagExEnemy.GetLocationX(), flagExEnemy.GetLocationY()) <= m_nD) &&
                                        (flagEx.GetLocationZ() == flagExEnemy.GetLocationZ()))
                                    {
                                        //captured flag
                                        rPlayer.SetScriptData(0, 0);
                                        rPlayer.Defeat();
                                        KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,0,200);//tym samym zabijamy tez flage
                                        KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,1,200);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(comboAlliedVictory)
            {
                bOneHasBeenDestroyed=false;
                for(i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    if(rPlayer!=null && !rPlayer.IsAlive()) 
                        bOneHasBeenDestroyed=true;
                }
                bActiveEnemies=false;
                for(i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    if(rPlayer!=null && rPlayer.IsAlive()) 
                    {
                        for(j=0;j<15;j=j+1)
                        {
                            rPlayer2 = GetPlayer(j);
                            if(rPlayer2!=null && rPlayer2.IsAlive() && !rPlayer.IsAlly(rPlayer2)) 
                            {
                                bActiveEnemies=true;
                            }
                        }
                    }
                }
                if(bActiveEnemies) return;
                if(!bOneHasBeenDestroyed) return;
                //sprawdzamy czy nie ma flag "niezywych" playerow ktore jeszcze nie zostaly zcapturowane
                //oraz czy zyjacy maja swoje flagi w bazie
                for (i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    if(rPlayer!=null) 
                    {
                        flagEx = rPlayer.GetScriptUnit(0);
                        if (!rPlayer.IsAlive())
                        {
                            if ((flagEx != null) && flagEx.IsLive())
                            {
                                return;
                            }
                        }
                        else
                        {
                            if (!HaveFlagInBase(rPlayer))
                            {
                                return;
                            }
                        }
                    }
                }
                for(i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    if(rPlayer!=null && rPlayer.IsAlive()) 
                    {
                        rPlayer.Victory();
                    }
                }
            }
            else
            {
                for(i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    if(rPlayer!=null && rPlayer.IsAlive()) 
                    {
                        iCountBuilding = rPlayer.GetNumberOfBuildings() + rPlayer.GetNumberOfUnits();
                        if (iCountBuilding>0)
                        {
                            iAlivePlayers=iAlivePlayers+1;
                            rLastPlayer=rPlayer;
                        }
                    }
                }
                if (iAlivePlayers==1 && rLastPlayer!=null)
                {
                    //sprawdzamy czy nie ma flag "niezywych" playerow ktore jeszcze nie zostaly zcapturowane
                    for (i=0;i<15;i=i+1)
                    {
                        rPlayer = GetPlayer(i);
                        if(rPlayer!=null && !rPlayer.IsAlive()) 
                        {
                            flagEx = rPlayer.GetScriptUnit(0);
                            if ((flagEx != null) && flagEx.IsLive())
                            {
                                return;
                            }
                        }
                    }
                    //sprawdzenie czy rLastPlayer ma flage w bazie
                    if (!HaveFlagInBase(rLastPlayer))
                    {
                        return;
                    }
                    rLastPlayer.Victory();
                }
            }
        }
        else
        {
            if (comboAlliedVictory)
            {
                //player (i jego alianci) wygrywa gdy on (lub jego alianci) maja swoje flagi w bazach
                //oraz wszystkie niealianckie flagi obok nich
                //oraz ci alianci powinni miec przynajmniej jednego wroga
                for(i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    bIsVictoryAlliance = true;
                    bHaveSomeEnemy = false;
                    if ((rPlayer != null) && rPlayer.IsAlive())
                    {
                        //sprawdzenie czy dla niego i jego playerow sa spelnione warunki zwyciestwa
                        for (j=0;j<15;j=j+1)
                        {
                            rPlayer2=GetPlayer(j);
                            if ((j==i) || (rPlayer2!=null) && rPlayer2.IsAlive() && rPlayer.IsAlly(rPlayer2))
                            {
                                if (!HaveAllFlagsCapturedByAllies(rPlayer2))
                                {
                                    bIsVictoryAlliance = false;
                                    break;
                                }
                                else
                                {
                                    for (k=0;k<15;k=k+1)
                                    {
                                        rEnemy=GetPlayer(k);
                                        if ((rEnemy!=null) && (k!=j) && !rPlayer2.IsAlly(rEnemy))
                                        {
                                            bHaveSomeEnemy = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (bIsVictoryAlliance && bHaveSomeEnemy)
                    {
                        //rPlayer i jego sprzymierzency wygrywaja, reszta przegrywa
                        //najpierw Defeat potem Victory
                        for (j=0;j<15;j=j+1)
                        {
                            rPlayer2=GetPlayer(j);
                            if (rPlayer2!=null)
                            {
                                if ((j==i) || rPlayer2.IsAlive() && rPlayer.IsAlly(rPlayer2))
                                {
                                    //victory dalej
                                }
                                else
                                {
                                    rPlayer2.SetScriptData(0, 0);
                                    rPlayer2.Defeat();
                                    KillArea(rPlayer2.GetIFF(),GetRight()/2,GetBottom()/2,0,200);//tym samym zabijamy tez flage
                                    KillArea(rPlayer2.GetIFF(),GetRight()/2,GetBottom()/2,1,200);
                                }
                            }
                        }
                        for (j=0;j<15;j=j+1)
                        {
                            rPlayer2=GetPlayer(j);
                            if (rPlayer2!=null)
                            {
                                if ((j==i) || rPlayer2.IsAlive() && rPlayer.IsAlly(rPlayer2))
                                {
                                    //victory
                                    rPlayer2.Victory();
                                }
                            }
                        }
                        break;
                    }
                }
            }
            else
            {
                //player wygrywa gdy ma swoja flage w poblizu punktu startowego, nie ma zadnego przyjaciela
                //i wszystkie pozostale flagi sa w poblizu jego flagi
                for(i=0;i<15;i=i+1)
                {
                    rPlayer = GetPlayer(i);
                    if(rPlayer!=null && rPlayer.IsAlive())
                    {
                        //sprawdzamy czy ma jakichs przyjaciol
                        for(j=0;j<15;j=j+1)
                        {
                            rPlayer2 = GetPlayer(j);
                            if ((j!=i) && (rPlayer2!=null) && rPlayer2.IsAlive() && rPlayer.IsAlly(rPlayer2))
                            {
                                return;
                            }
                        }
                        //nie ma przyjaciol, sprawdzamy flage
                        if (HaveFlagInBase(rPlayer))
                        {
                            flagEx = rPlayer.GetScriptUnit(0);
                            //sprawdzamy czy pozostale flagi sa w jej poblizu
                            for (j=0;j<15;j=j+1)
                            {
                                rPlayer2 = GetPlayer(j);
                                if ((j!=i) && (rPlayer2!=null))//nie sprawdzamy IsAlive bo potrzebujemy wszystkich flag
                                {
                                    flagExEnemy = rPlayer2.GetScriptUnit(0);
                                    if ((flagExEnemy == null) || !flagExEnemy.IsLive() || flagExEnemy.IsTransported() ||
                                        (Distance(flagExEnemy.GetLocationX(), flagExEnemy.GetLocationY(), flagEx.GetLocationX(), flagEx.GetLocationY()) > m_nD) ||
                                        (flagExEnemy.GetLocationZ() != flagEx.GetLocationZ()))
                                    {
                                        return;
                                    }
                                }
                            }
                            //rPlayer ma wszystkie flagi - zwyciezyl
                            rLastPlayer = rPlayer;
                        }
                    }
                }
                if (rLastPlayer!=null)
                {
                    for(i=0;i<15;i=i+1)
                    {
                        rPlayer = GetPlayer(i);
                        if((rPlayer!=null) && (rPlayer!=rLastPlayer))
                        {
                            rPlayer.SetScriptData(0, 0);
                            rPlayer.Defeat();
                            KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,0,200);//tym samym zabijamy tez flage
                            KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,1,200);
                        }
                    }
                    rLastPlayer.Victory();
                }
            }
        }
    }
    event Timer4()
    {
        int i;
        player rPlayer;
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
                if(rPlayer.GetMaxDistance()<255)
                    rPlayer.SetMaxDistance(rPlayer.GetMaxDistance()+1);
            }
        }
    }

    event Timer5()
    {
        int i;
        int j;
        player rPlayer;
        player rPlayer2;
        //sprawdzanie zenablowania szpiegowania 
        //(po 10 minutach - warunek player ma 2 lub mniej budynki inne niz wiezyczki
        //i 4 lub mniej wiezyczki i 6 lub mniej unitow)
        //jesli warunek nie jest spelniony to z powrotem disablujemy szpiegowanie
        if (GetMissionTime() > 10*60*20)
        {
            for (i = 0; i < 15; i = i + 1)
            {
                rPlayer = GetPlayer(i);
                if ((rPlayer != null) && rPlayer.IsAlive())
                {
                    if ((rPlayer.GetNumberOfBuildings(buildingNormal) <= 4) &&
                        ((rPlayer.GetNumberOfBuildings() - rPlayer.GetNumberOfBuildings(buildingNormal)) <= 2) &&
                        (rPlayer.GetNumberOfUnits() <= 6))
                    {
                        for (j = 0; j < 15; j = j + 1)
                        {
                            rPlayer2 = GetPlayer(j);
                            if ((j != i) && (rPlayer2 != null) && rPlayer2.IsAlive() && !rPlayer2.IsAlly(rPlayer))
                            {
                                if (rPlayer2.IsCommandDisabled(commandBuildingSpyPlayer0 + i))
                                    rPlayer2.EnableCommand(commandBuildingSpyPlayer0 + i, true);
                            }
                        }
                    }
                    else
                    {
                        for (j = 0; j < 15; j = j + 1)
                        {
                            rPlayer2 = GetPlayer(j);
                            if ((j != i) && (rPlayer2 != null) && rPlayer2.IsAlive())
                            {
                                if (rPlayer2.IsCommandEnabled(commandBuildingSpyPlayer0 + i))
                                    rPlayer2.EnableCommand(commandBuildingSpyPlayer0 + i, false);
                            }
                        }
                    }
                }
            }
        }
    }
    
    command Initialize()
    {
        comboCTFType=0;
        comboResearchTime=0;
        comboCashType=1;
        comboAlliedVictory=1;
        comboUnitsLimit=2;
    }
    
    command Uninitialize()
    {
        ResourcesPerContainer(8);
    }
    
    command Combo1(int nMode) button comboCTFType
    {
        comboCTFType = nMode;
    }
    
    command Combo2(int nMode) button comboCashType 
    {
        comboCashType = nMode;
    }
    
    command Combo3(int nMode) button comboResearchTime
    {
        comboResearchTime = nMode;
    }
    
    command Combo4(int nMode) button comboResearchLimit
    {
        comboResearchLimit = nMode;
    }
    command Combo5(int nMode) button comboUnitsLimit
    {
        comboUnitsLimit = nMode;
    }
    command Combo6(int nMode) button comboAlliedVictory
    {
        comboAlliedVictory = nMode;
    }
}
