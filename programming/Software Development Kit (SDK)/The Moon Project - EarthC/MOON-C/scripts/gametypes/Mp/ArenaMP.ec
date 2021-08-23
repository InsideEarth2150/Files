mission "translateGameTypeArena"
{
    
    int bDemo;    
    int nTimeLimit;
    
    int bCheckBuilding;
    int nMeteor;
    int nPlayerInConsole;   
    enum comboTechLevel
    {
        "translateGameMenuTechLevelLow",
        "translateGameMenuTechLevelMedium",
        "translateGameMenuTechLevelHigh",
multi:
        "translateGameMenuTechLevel"
    }
    enum comboStartingUnits
    {
        "1",
        "2",
        "3",
multi:
        "translateGameMenuStartingUnits"
    }
    enum comboTime
    {
        "translateGameMenuTimeLimitNoLimit",
        "translateGameMenuTimeLimit15min",
        "translateGameMenuTimeLimit30min",
        "translateGameMenuTimeLimit45min",
        "translateGameMenuTimeLimit1h",
        "translateGameMenuTimeLimit15h",
multi:
        "translateGameMenuTimeLimit"
    }
    
    //********************************************************
    //********* F U N C T I O N S ****************************
    //********************************************************
    function int CreateArtefacts(player rPlayer)
    {
        int i;
        int x;
        int y;
        if(!rPlayer)return false;
        x = rPlayer.GetStartingPointX();
        y = rPlayer.GetStartingPointY();
        
        CreateArtefact("NEAAMMO",x,  y  ,0,-1,-1);
        CreateArtefact("NEAAMMO",x-1,y  ,0,-1,-1);
        CreateArtefact("NEAAMMO",x+1,y  ,0,-1,-1);
        
        CreateArtefact("NEAENERGY",x,  y+1,0,-1,-1);
        CreateArtefact("NEAENERGY",x-1,y+1,0,-1,-1);
        CreateArtefact("NEAENERGY",x+1,y+1,0,-1,-1);
        
        CreateArtefact("NEAMAXHP",x,  y-1,0,-1,-1);
        CreateArtefact("NEAMAXHP",x-1,y-1,0,-1,-1);
        CreateArtefact("NEAMAXHP",x+1,y-1,0,-1,-1);
        
        
        CreateArtefact("NEASHOWMAP0",x,  y+2,0,-1,-1);
        return true;
    }
    
    function int CreateStartingUnits(player rPlayer,player rPlayer2)
    {
        int x;
        int y;
        if(!rPlayer)return false;
        if(!rPlayer2)return false;
        x = rPlayer2.GetStartingPointX();
        y = rPlayer2.GetStartingPointY();
        
        if(comboTechLevel==0)
        {
            if (rPlayer.GetRace()==raceED)
            {
                
                                rPlayer.CreateUnitEx(x,y,  0,null,"EDUMT3","EDWSL1",null,null,null,0);                  
                if(comboStartingUnits>0)
                                    rPlayer.CreateUnitEx(x+1,y,  0,null,"EDUST3","EDWCA2",null,null,null);                        
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,  0,null,"EDUMW3","EDWSR3",null,null,null,0);                  
            }
            if (rPlayer.GetRace()==raceLC)
            {
                rPlayer.CreateUnitEx(x,y,  0,null,"LCUMO2","LCWSL1",null,null,null,0);                    
                if(comboStartingUnits>0)
                    rPlayer.CreateUnitEx(x+1,  y,0,null,"LCUMO3","LCWSR3",null,null,null);                  
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,0,null,"LCUMO2","LCWSS2",null,null,null,0);                    
            }
            if (rPlayer.GetRace()==raceUCS)
            {
                                rPlayer.CreateUnitEx(x,y,0,null,"UCSUML3","UCSWSSP2",null,null,null,2);                 
                if(comboStartingUnits>0)
                    rPlayer.CreateUnitEx(x+1,y,0,null,"UCSUSL3","UCSWTSR3",null,null,null);                 
                if(comboStartingUnits>1)
                                        rPlayer.CreateUnitEx(x-1,y,  0,null,"UCSUML3","UCSWSMR1",null,null,null,2);                     
            }
        }
        if(comboTechLevel==1)
        {
            if (rPlayer.GetRace()==raceED)
            {
                rPlayer.CreateUnitEx(x,y,  0,null,"EDUHT3","EDWMR3",null,null,null,1);                    
                if(comboStartingUnits>0)
                    rPlayer.CreateUnitEx(x+1,y,  0,null,"EDUHW2","EDWHL2",null,"EDWSL2",null,2);                  
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,  0,null,"EDUHT3","EDWHC2",null,"EDWSR3",null,1);                  
            }
            if (rPlayer.GetRace()==raceLC)
            {
                rPlayer.CreateUnitEx(x,y,  0,null,"LCUCR1","LCWMR3",null,null,null,2);                    
                if(comboStartingUnits>0)
                    rPlayer.CreateUnitEx(x+1,  y,0,null,"LCUCR1","LCWHL1",null,"LCWSL1",null,2);                  
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,0,null,"LCUCR1","LCWHS2",null,null,null,2);                    
            }
            if (rPlayer.GetRace()==raceUCS)
            {
                rPlayer.CreateUnitEx(x,y,  0,null,"UCSUHL3","UCSWBMR3",null,null,null,2);                 
                if(comboStartingUnits>0)
                    rPlayer.CreateUnitEx(x+1,y,0,null,"UCSUHL3","UCSWBHP3",null,"UCSWSSP2",null,2);                 
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,0,null,"UCSUHL3","UCSWBSR3",null,"UCSWSSR3",null,2);                   
            }
        }
        if(comboTechLevel==2)
        {
            if (rPlayer.GetRace()==raceED)
            {
                rPlayer.CreateUnitEx(x,y,  0,null,"EDUHW2","EDWHL3",null,"EDWSL3",null,2);                  
                if(comboStartingUnits>0)
                                    rPlayer.CreateUnitEx(x+1,y,  0,null,"EDUBT2","EDWMR3","EDWMR3",null,null,1);                    
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,  0,null,"EDUHT3","EDWHC2",null,"EDWSR3",null,1);                  
            }
            if (rPlayer.GetRace()==raceLC)
            {
                rPlayer.CreateUnitEx(x,y,0,null,"LCUCR3","LCWHL2",null,"LCWSL2",null,2);                    
                if(comboStartingUnits>0)
                    rPlayer.CreateUnitEx(x+1,y,  0,null,"LCUCU3","LCWMR3","LCWMR3",null,null,1);                    
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,0,null,"LCUCU3","LCWHL2","LCWHL2","LCWSS2","LCWSS2",1);                    
            }
            if (rPlayer.GetRace()==raceUCS)
            {
                                rPlayer.CreateUnitEx(x,y,0,null,"UCSUBL2","UCSWBHP3","UCSWSSP2","UCSWSSP2",null,2);                 
                if(comboStartingUnits>0)
                                        rPlayer.CreateUnitEx(x+1,y,  0,null,"UCSUBL2","UCSWBMR3","UCSWSSR3",null,null,2);                       
                if(comboStartingUnits>1)
                    rPlayer.CreateUnitEx(x-1,y,0,null,"UCSUBL2","UCSWBHP3","UCSWSSP2","UCSWSSP2",null,2);                 
            }
        }
        rPlayer.SetScriptData(1,rPlayer.GetNumberOfUnits());
        return true;
  }
  //------------------------------------------------------- 
  
  state Initialize;
  state Nothing;
  
  state Initialize
  {
      player rPlayer;
      int i;
      int nStartingMoney;
      
      if(comboTime==0)nTimeLimit=0;
      if(comboTime==1)nTimeLimit=15*60*20;
      if(comboTime==2)nTimeLimit=30*60*20;
      if(comboTime==3)nTimeLimit=45*60*20;
      if(comboTime==4)nTimeLimit=60*60*20;
      if(comboTime==5)nTimeLimit=90*60*20;
      
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

      bCheckBuilding=false;
      for(i=0;i<15;i=i+1)
      {
          rPlayer=GetPlayer(i);
          if(rPlayer!=null) 
          {
                rPlayer.AddResearch("RES_MISSION_PACK1_ONLY");
                            rPlayer.SetAllowGiveUnits(false);
              rPlayer.EnableAIFeatures2(ai2BNSendResult,false);//nie wysylac rezultatow do EARTH NETu
                            rPlayer.AddResearch("RES_MSR2");
                            rPlayer.AddResearch("RES_MSR3");
                            rPlayer.AddResearch("RES_MSR4");
                            rPlayer.AddResearch("RES_MMR2");
                            rPlayer.AddResearch("RES_MMR3");
                            rPlayer.AddResearch("RES_MMR4");
                            if (rPlayer.GetRace()==raceUCS)
                            {
                                rPlayer.AddResearch("RES_UCS_SGen");
                                rPlayer.AddResearch("RES_UCS_MGen");
                                rPlayer.AddResearch("RES_UCS_HGen");
                            }
                            if (rPlayer.GetRace()==raceED)
                            {
                                rPlayer.AddResearch("RES_ED_SGen");
                                rPlayer.AddResearch("RES_ED_MGen");
                                rPlayer.AddResearch("RES_ED_HGen");
                            }
                            if (rPlayer.GetRace()==raceLC)
                            {
                                rPlayer.AddResearch("RES_LC_SGen");
                                rPlayer.AddResearch("RES_LC_MGen");
                                rPlayer.AddResearch("RES_LC_HGen");
                            }

              rPlayer.SetMaxTankPlatoonSize(1);
              rPlayer.SetNumberOfOffensiveTankPlatoons(4);
              rPlayer.SetNumberOfDefensiveTankPlatoons(0);
              rPlayer.SetNumberOfDefensiveShipPlatoons(0);
              rPlayer.SetNumberOfDefensiveHelicopterPlatoons(0);
              rPlayer.EnableAIFeatures(aiRush,true);
              rPlayer.EnableAIFeatures(aiBuildBuildings,false);
              rPlayer.EnableAIFeatures2(ai2NeutralAI,false);//kazdy na kazdego
              rPlayer.SetMaxAttackFrequency(20);

              rPlayer.SetMoney(0);
              rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
              CreateStartingUnits(rPlayer,rPlayer);
              CreateArtefacts(rPlayer);
              rPlayer.SetScriptData(0,0);
          }
      }
      SetTimer(0,23);//respawn
      SetTimer(1,1200);
      SetTimer(2,53);//console
      
      nMeteor=1;
      return Nothing;
  }
  
  state Nothing
  {
      return Nothing;
  }
  
  event RemoveResources()
  {
      true;
  }
  
  event RemoveUnits()
  {
      true;
  }
  
  event Timer2()
  {
      int i;
      int k;
      player rPlayer;
      player rPlayer2;
      
      rPlayer=null;
      for(i=nPlayerInConsole+1;i<15 && rPlayer==null;i=i+1)
      {
          rPlayer=GetPlayer(i);
          if(rPlayer!=null)nPlayerInConsole=i;
      }
      if(rPlayer==null)
      {
          nPlayerInConsole=0;
          for(i=0;i<15 && rPlayer==null;i=i+1)
          {
              rPlayer=GetPlayer(i);
              if(rPlayer!=null)nPlayerInConsole=i;
          }
      }
      
      
      if(rPlayer!=null)
      {
          k=1;
          for(i=0;i<15;i=i+1)
          {
              rPlayer2=GetPlayer(i);
              if(rPlayer2!=null && (rPlayer.GetScriptData(0) < rPlayer2.GetScriptData(0))) k = k+1;
          }
          
          SetConsoleTextCol(rPlayer.GetIFFNumber(),"translateArenaStatistics",k,rPlayer.GetName(),rPlayer.GetScriptData(0));//XXXdodac kolor
      }
  }
  
  event Timer0()
  {
      int i;
            int nPlayersCount;
      player rPlayer;
      player rPlayer2;
            player rLastPlayer;
      
            nPlayersCount=0;
      for(i=0;i<15;i=i+1)
      {
          rPlayer = GetPlayer(i);
          if(rPlayer!=null && rPlayer.IsAlive()) 
          {
                        nPlayersCount=nPlayersCount+1;
                        rLastPlayer=rPlayer;
              if(!rPlayer.GetScriptData(1))
              {
                  rPlayer2 = GetPlayer(nPlayerInConsole);
                  if(rPlayer2==null)rPlayer2 = rPlayer;
                  rPlayer.LookAt(rPlayer2.GetStartingPointX(),rPlayer2.GetStartingPointY(),-1,-1,-1,0);
                  CreateStartingUnits(rPlayer,rPlayer2);
              }
          }
      }
            if(nPlayersCount==1)
                rLastPlayer.Victory();
  }
  
  event Timer1()
  {
      int i;
      player rPlayer;
      player rBestPlayer;
      int bestScore;
      
      bCheckBuilding=true;
      if(nTimeLimit)
      {
          if(GetMissionTime()>nTimeLimit)
          {
              for(i=0;i<15;i=i+1)
              {
                  rPlayer=GetPlayer(i);
                  if(rPlayer!=null) 
                  {
                      if(rPlayer.GetScriptData(0)>bestScore)
                          bestScore = rPlayer.GetScriptData(0);
                  }
              }
              for(i=0;i<15;i=i+1)
              {
                  rPlayer=GetPlayer(i);
                  if(rPlayer!=null && rPlayer.IsAlive()) 
                  {
                      if(rPlayer.GetScriptData(0)==bestScore)
                          rPlayer.Victory();
                      else
                          rPlayer.Defeat();
                  }
              }
          }
      }
  }
  
  event UnitDestroyed(unit uUnit)
  {
      unit uAttacker;
      player pAttacker;
      player pDestroyed;
      int tmp;
      pAttacker = GetPlayer(uUnit.GetIFFNumber());
      pAttacker.SetScriptData(1,pAttacker.GetScriptData(1)-1);
      uAttacker = uUnit.GetAttacker();
      if(uAttacker==null) return false;
      pAttacker = GetPlayer(uAttacker.GetIFFNumber());
      if(uAttacker.GetIFFNumber()==uUnit.GetIFFNumber())
          tmp = pAttacker.GetScriptData(0)-1;
      else
          tmp = pAttacker.GetScriptData(0)+1;
      pAttacker.SetScriptData(0,tmp);
      
      return true;
  }
  
  command Initialize()
  {
      comboStartingUnits=1;
  }
  
  command Uninitialize()
  {
      ResourcesPerContainer(8);
  }
  
  command Combo1(int nMode) button comboTechLevel
  {
      comboTechLevel = nMode;
  }
  
  command Combo2(int nMode) button comboStartingUnits 
  {
      comboStartingUnits = nMode;
  }
  command Combo3(int nMode) button comboTime 
  {
      comboTime = nMode;
  }
  
}

