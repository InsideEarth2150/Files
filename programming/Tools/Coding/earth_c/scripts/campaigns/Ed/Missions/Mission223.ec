mission "translateMission223"
{//Alaska - Mine 100 000 resources
    consts
    {
        destroyEnemyBase = 0;
        sendToBase100000 = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_GoalEnemy;
    player p_Player;
    int bShowFailed;  
    
    state Initialize;
    state ShowBriefing;
    state DestroyEnemyBase;
    state ShowVideoState;
    state Mining;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(destroyEnemyBase,"translateGoal223a");
        RegisterGoal(sendToBase100000,"translateGoal223b",0);
        EnableGoal(destroyEnemyBase,true);           
        EnableGoal(sendToBase100000,true);           
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(5);
        p_GoalEnemy = GetPlayer(4);
        
        p_Player.SetEnemy(p_GoalEnemy);
        
        p_Player.SetMoney(20000);
        p_Enemy1.SetMoney(20000);
        p_Enemy2.SetMoney(20000);
        p_GoalEnemy.SetMoney(12000);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_GoalEnemy.LoadScript("single\\singleEasy");
            p_GoalEnemy.EnableAIFeatures(aiDefenseTowers,false);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_GoalEnemy.LoadScript("single\\singleMedium");
            p_GoalEnemy.EnableAIFeatures(aiDefenseTowers,false);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_GoalEnemy.LoadScript("single\\singleMedium");
        }
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_GoalEnemy.EnableAIFeatures(aiControlOffense,false);
        
        
        p_Enemy1.SetNumberOfOffensiveTankPlatoons(4);
        p_Enemy2.SetNumberOfOffensiveTankPlatoons(0);
        
        
        p_GoalEnemy.SetMaxTankPlatoonSize(3);
        
        p_GoalEnemy.SetNumberOfOffensiveTankPlatoons(0);
        p_GoalEnemy.SetNumberOfOffensiveShipPlatoons(0);
        p_GoalEnemy.SetNumberOfOffensiveHelicopterPlatoons(0);
        
        p_GoalEnemy.SetNumberOfDefensiveTankPlatoons(4);
        p_GoalEnemy.SetNumberOfDefensiveShipPlatoons(0);
        p_GoalEnemy.SetNumberOfDefensiveHelicopterPlatoons(0);
        
        
        ShowArea(4,p_GoalEnemy.GetStartingPointX(),p_GoalEnemy.GetStartingPointY(),0,2);
        
        p_Enemy1.EnableResearch("RES_UCS_WSG1",true);
        p_Enemy1.EnableResearch("RES_MSR2",true);
        p_Enemy1.EnableResearch("RES_UCS_UML1",true);
        p_Enemy1.EnableResearch("RES_UCS_BMD",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_GoalEnemy.CopyResearches(p_Enemy1);
        
        p_Player.EnableResearch("RES_ED_WSR2",true);
        p_Player.EnableResearch("RES_ED_UA21",true);
        p_Player.EnableResearch("RES_ED_BMD",true);
        
        // 1st tab
        p_Player.EnableBuilding("EDBPP",true);
        p_Player.EnableBuilding("EDBBA",true);
        p_Player.EnableBuilding("EDBFA",true);
        p_Player.EnableBuilding("EDBWB",true);
        p_Player.EnableBuilding("EDBAB",true);
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",true);
        p_Player.EnableBuilding("EDBMI",true);
        p_Player.EnableBuilding("EDBTC",true);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",true);
        // 4th tab
        p_Player.EnableBuilding("EDBHQ",true);
        p_Player.EnableBuilding("EDBRA",true);
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
        
        SetTimer(0,200);
        SetTimer(1,6000);
        bShowFailed=true;
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
  }
  //-----------------------------------------------------------------------------------------
  state ShowBriefing
  {
      AddBriefing("translateBriefing223a");
      //EnableEndMissionButton(true);//XXXMD!!!!!!!usunac
      return DestroyEnemyBase,1200;
  }
  
  //-----------------------------------------------------------------------------------------
  state DestroyEnemyBase
  {
      if(!p_GoalEnemy.GetNumberOfBuildings())
      {
          EnableNextMission(0,true);
          SetGoalState(destroyEnemyBase, goalAchieved);
          AddBriefing("translateBriefing223b");//transmisja ze program badawczy.
          p_Enemy1.EnableAIFeatures(aiControlOffense,true);
          p_Enemy2.EnableAIFeatures(aiControlOffense,true);
          return ShowVideoState,20;
      }
      return DestroyEnemyBase,100;
  }
  //-----------------------------------------------------------------------------------------
  state ShowVideoState
  {
      ShowVideo("CS210");
      return Mining,500;
  }
  //-----------------------------------------------------------------------------------------
  state Mining
  {
      if(GetGoalState(sendToBase100000)!=goalAchieved && p_Player.GetMoneySentToBase()>=100000)
      {
          SetGoalState(sendToBase100000, goalAchieved);
          AddBriefing("translateAccomplished223");
          EnableEndMissionButton(true);
          return Evacuate,500;
      }
      return Mining,100;
  }
  //-----------------------------------------------------------------------------------------
  state Evacuate
  {
      return Evacuate,500;
  }
  //-----------------------------------------------------------------------------------------
  event Timer0()
  {
      RegisterGoal(sendToBase100000,"translateGoal223b",p_Player.GetMoneySentToBase());
      
      if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
      {
          AddBriefing("translateFailed223b");
          EndMission(false);
      }
      if(bShowFailed)
      {
          //  SetConsoleText("l:<%0>, p:<%1>, s:<%2>",ResourcesLeftInMoney(),p_Player.GetMoney(),p_Player.GetMoneySentToBase());
          if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<100000)
          {
              bShowFailed=false;
              SetGoalState(sendToBase100000, goalFailed);
              AddBriefing("translateFailed223a");
              EnableEndMissionButton(true);
              return Evacuate;
          }
      }
  }
  //-----------------------------------------------------------------------------------------
  event Timer1()
  {
      Snow(p_GoalEnemy.GetStartingPointX(),p_GoalEnemy.GetStartingPointY(),40,400,2500,800,4); 
  }
}
