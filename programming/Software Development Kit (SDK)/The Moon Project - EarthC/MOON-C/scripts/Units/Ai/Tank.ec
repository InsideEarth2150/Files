tank "translateScriptNameTank"
{
    consts
    {
        disableFire=0;
        enableFire=1;
    }
    
    
    
    unit m_uTarget;
    int  m_nCannonsCount;
    int  m_nTargetGx;
    int  m_nTargetGy;
    int  m_nTargetLz;
    int  m_nStayGx;
    int  m_nStayGy;
    int  m_nStayLz;
    int  m_nSpecialCounter;
    unit m_uSpecialUnit;
    int  m_bFindAndDestroyWalls;
    
    enum lights
    {
        "translateCommandStateLightsAUTO",
        "translateCommandStateLightsON",
        "translateCommandStateLightsOFF",
multi:
        "translateCommandStateLightsMode"
    }
    
    
    enum traceMode
    {
        "translateCommandStateTraceOFF",
        "translateCommandStateTraceON",
multi:
        "translateCommandStateTraceMode"
    }
    //********************************************************
    //********* F U N C T I O N S ****************************
    //********************************************************
    //-------------------------------------------------------
    function int SetTarget(unit uTarget)
    {
        m_uTarget = uTarget;
        SetTargetObject(uTarget);
        return true;
    }
    //------------------------------------------------------- 
    function int GoToPoint()
    {
        int nRangeMode;
        int nDx;
        int nDy;
        nRangeMode = IsPointInCannonRange(0,m_nTargetGx, m_nTargetGy, m_nTargetLz);
        
        if (nRangeMode == 4) //in range
        {
            if (IsMoving())
                CallStopMoving();
            return false;
        }
        if(nRangeMode == 1) //w zasiegu ale trzeba odwrocic czolg 
        {
            if (IsMoving())
                CallStopMoving();
            else
                CallTurnToAngle(GetCannonAngleToPoint(0,m_nTargetGx, m_nTargetGy, m_nTargetLz));
            
            return true;
        }
        
        CallMoveToPoint(m_nTargetGx, m_nTargetGy, m_nTargetLz);
        return true;
    }
    
    //------------------------------------------------------- 
    function int GoToTarget()
    {
        int nRangeMode;
        nRangeMode = IsTargetInCannonRange(0, m_uTarget);
        
        if (nRangeMode == inRangeGoodHit)
        {
            if(traceMode)   TraceD("GoToTarget: In range                               \n");
            if (IsMoving())
                CallStopMoving();
            return false;
        }
        
        if(nRangeMode == inRangeBadAngleAlpha) //w zasiegu ale trzeba odwrocic czolg 
        {
            if(traceMode)   TraceD("GoToTarget: Rotating tank:");
            CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
            return true;
        }
        CallMoveToPoint(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
        return true;
    }
    
    //-------------------------------------------------------
    function int EndState()
    {
        SetCannonFireMode(-1, disableFire);
        NextCommand(1);
    }
    //-------------------------------------------------------
    function int FindBestTarget()
    {
        int i;
        int nTargetsCount;
        unit newTarget;
        int nFindTarget;
        
        if(GetCannonType(0) != cannonTypeIon)
        {
            nFindTarget = 0;
            if (CanCannonFireToAircraft(-1))
            {
                nFindTarget = findTargetFlyingUnit;
            }
            if (CanCannonFireToGround(-1))
            {
                if (GetCannonType(0) == cannonTypeEarthquake)
                {
                    nFindTarget = nFindTarget | findTargetBuildingUnit;
                }
                else
                {
                    nFindTarget = nFindTarget | findTargetNormalUnit | findTargetWaterUnit | findTargetBuildingUnit;
                }
            }
            SetTarget(FindClosestEnemyUnitOrBuilding(nFindTarget));
            return true;
        }
        
        SetTarget(null);
        BuildTargetsArray(findTargetWaterUnit|findTargetNormalUnit|findTargetBuildingUnit, findEnemyUnit,findDestinationAnyUnit);
        SortFoundTargetsArray();
        nTargetsCount=GetTargetsCount();
        if(nTargetsCount!=0)
        {
            StartEnumTargetsArray();
            for(i=0;i<nTargetsCount;i=i+1)
            {
                newTarget = GetNextTarget();
                if(!newTarget.IsDisabled())
                {
                    EndEnumTargetsArray();
                    SetTarget(newTarget);
                    return true;
                }
            }
            EndEnumTargetsArray();
            return false;
        }
        else
        {
            return false;
        }
    }
    //********************************************************
    //************* S T A T E S ******************************
    //********************************************************
    state Nothing;
    state InPlatoonState;
    state StartMoving;
    state Moving;
    state AutoAttacking;
    state Attacking;
    state AttackingPoint;
    state Retreat;
    //------------------------------------------------------- 
    state Retreat
    {
        if(IsMoving())
            return Retreat,20;
        
        m_uTarget = FindClosestEnemy();
        SetTargetObject(null);
        
        if(!m_uTarget)
        {
            if(IsMoving())
                CallStopMoving();
            m_uTarget = null;
            SetTargetObject(null);
            if(traceMode)TraceD("R->N                                                 \n");
            return Nothing;
        }
        CallMoveToPoint(2*GetLocationX()-m_uTarget.GetLocationX(),2*GetLocationY() - m_uTarget.GetLocationY(),GetLocationZ());
        if(traceMode)TraceD("R u                                                \n");
        return Retreat,100;
    }
    //------------------------------------------------------- 
    state InPlatoonState
    {
        if(traceMode)   TraceD("IP\n");
        if(!InPlatoon()) 
        {
            SetLightsMode(lights);
            SetCannonFireMode(-1, disableFire);
            return Nothing;
        }
        return InPlatoonState,40;
    }
    //------------------------------------------------------- 
    
    state Nothing
    {
        if(traceMode)TraceD("N                                                 \n");
        if(InPlatoon())
        {
            SetCannonFireMode(-1, enableFire);
            return InPlatoonState;
        }
        
        SetTarget(GetAttacker());
        ClearAttacker();
        
        if(!m_uTarget)
        {
            FindBestTarget(); 
        }
        
        if (m_uTarget != null)
        {
            m_nStayGx = GetLocationX();
            m_nStayGy = GetLocationY();
            m_nStayLz = GetLocationZ();
            return AutoAttacking;
        }
        return Nothing;
    }
    //----------------------------------------------------
    state AutoAttacking
    {
        int nDistance;
        
        if(traceMode)TraceD("AA                                                \n");
        
        // pozostawaj w okolicach punktu
        nDistance = DistanceTo(m_nStayGx,m_nStayGy);
        if( nDistance > 12)
        {
            if(traceMode)TraceD("nDistance: > 12 !!!!!                                                \n  ");
            SetTarget(null);
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
            SetCannonFireMode(-1, enableFire);
            return Moving;          
        }
        
        if(!m_uTarget.IsLive() || (GetCannonType(0) == cannonTypeIon && m_uTarget.IsDisabled()))
        {
            StopCannonFire(-1);
            SetTarget(null);
        }
        
        if (m_uTarget)
        {
            if(!GoToTarget())
            {
                if(traceMode)TraceD("AA    Fire!!!!                                           \n");
                CannonFireToTarget(-1, m_uTarget, -1);
                if(GetAttacker()!=null){ SetTarget(GetAttacker()); ClearAttacker(); }
            }
            return AutoAttacking;
        }
        else//target not exist
        {
            SetTarget(GetAttacker());
            ClearAttacker();
            
            if(!m_uTarget)
            {
                FindBestTarget();
            }
            
            if (m_uTarget != null)
                return AutoAttacking;
            
            
            if( nDistance > 0)
            {
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                SetCannonFireMode(-1, enableFire);
                return Moving;          
            }
            
            if (IsMoving())
            {
                CallStopMoving();
            }
            return Nothing;
        }
    }
    //--------------------------------------------------------------------------
    state AttackingPoint
    {
        if(traceMode)TraceD("AG                                                \n");
        if(GoToPoint())
        {
            return AttackingPoint;
        }
        else
        {
            CannonFireGround(-1, m_nTargetGx, m_nTargetGy, m_nTargetLz, 1);
            return AttackingPoint;
        }
    }
    //----------------------------------------------------
    state Attacking
    {
        if(traceMode)TraceD("A                                                \n");
        if (m_uTarget.IsLive())
        {
            if(GoToTarget())
            {
                return Attacking;
            }
            else
            {
                CannonFireToTarget(-1, m_uTarget, -1);
                return Attacking;
            }
        }
        else //target not exist
        {
            SetTarget(null);
            if (IsMoving())
            {
                CallStopMoving();
            }
            EndState();
            return Nothing;
        }
    }
    
    //--------------------------------------------------------------------------
    state StartMoving
    {
        return Moving, 20;
    }
    //--------------------------------------------------------------------------
    state Moving
    {
    /*ten kawalek jest teraz w plutonie  
    SetTarget(GetAttacker());
    ClearAttacker();
    
      if(!m_uTarget)
      {
      FindBestTarget(); 
      }
      
        if (m_uTarget != null)
        {
        return AutoAttacking;
    }*/
        
        if (IsMoving())
        {
            if(traceMode)   TraceD("Moving                                                \n");
            return Moving;
        }
        else
        {
            if(traceMode) TraceD("Moving -> N                                           \n");
            EndState(); 
            return Nothing;
        }
    }
    //--------------------------------------------------------------------------
    state Froozen
    {
        if (IsFroozen())
        {
            state Froozen;
        }
        else
        {
            //!!wrocic do tego co robilismy
            state Nothing;
        }
    }
    
    
    
    //********************************************************
    //*********** E V E N T S ****************************
    //********************************************************
    //zwracaja true
    //false jak nie ma 
    event OnHit()
    {
        if(!GetAmmoCount() && CannonRequiresSupply(-1))
        {
            SetCannonFireMode(-1, enableFire);
            if(traceMode)TraceD("NoAmmo -> R                                           \n");
            state Retreat;
        }
        true;
    }
    //------------------------------------------------------- 
    event OnCannonLowAmmo(int nCannonNum)
    {
        true;
    }
    //------------------------------------------------------- 
    event OnCannonNoAmmo(int nCannonNum)
    {
        if(CannonRequiresSupply(nCannonNum))// && !InPlatoon())
        {
            m_nSpecialCounter=0;
            SetCannonFireMode(-1, enableFire);
            if(traceMode)TraceD("NoAmmo -> R                                           \n");
            state Retreat;
        }
        true;
    }
    //------------------------------------------------------- 
    event OnCannonFoundTarget(int nCannonNum, unit uTarget)
    {
        if(GetCannonType(nCannonNum) == cannonTypeIon)
        {
            if(uTarget.IsDisabled())
            {
                return true;
            }
        }
        return false;//gdyby zwrocic true to dzialko nie strzeli
    }
    //------------------------------------------------------- 
    event OnCannonEndFire(int nCannonNum, int nEndStatus)//gdy zniszczony, poza zasiegiem lub brak ammunicji
    {
        false;
    }
    //------------------------------------------------------- 
    event OnFreezeForSupplyOrRepair(int nFreezeTicks)
    {
        CallFreeze(nFreezeTicks);
        state Froozen;
        true;
    }
    //------------------------------------------------------- 
    event OnTransportedToNewWorld()
    {
        StopCannonFire(-1);
        SetCannonFireMode(-1, disableFire);
        SetTarget(null);
        m_uSpecialUnit = null;
    }
    //------------------------------------------------------- 
    event OnConvertedToNewPlayer()
    {
        StopCannonFire(-1);
        SetCannonFireMode(-1, disableFire);
        SetTarget(null);
                ClearAttacker();
        m_uSpecialUnit = null;
        state Nothing;
    }
    
    //********************************************************
    //*********** C O M M A N D S ****************************
    //********************************************************
    command Initialize()
    {
        m_nCannonsCount = GetCannonsCount();
        traceMode = 0;
        SetCannonFireMode(-1, disableFire);
    }
    //--------------------------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
        SetTarget(null);
        m_uSpecialUnit = null;
    }
    //--------------------------------------------------------------------------
    command SetLights(int nMode) hidden button lights priority 204
    {
        if (nMode == -1)
        {
            lights = (lights + 1) % 3;
        }
        else
        {
            assert(nMode == 0);
            lights = nMode;
        }
        SetLightsMode(lights);
        NextCommand(0);
    }
    //--------------------------------------------------------------------------
    command Stop() hidden button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        SetTarget(null);
        StopCannonFire(-1);
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        if(IsMoving())
            CallStopMoving();
        SetCannonFireMode(-1, disableFire);
        state Nothing;
    }
    //--------------------------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) hidden button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        SetTarget(null);
        m_nStayGx = nGx;
        m_nStayGy = nGy;
        m_nStayLz = nLz;
        SetCannonFireMode(-1, enableFire);
        CallMoveToPoint(nGx, nGy, nLz);
        state StartMoving;
    }
    //--------------------------------------------------------------------------
    command Attack(unit uTarget) hidden button "translateCommandAttack" description "translateCommandAttackDescription" hotkey priority 22
    {
              if((CanCannonFireToAircraft(-1) || !uTarget.IsHelicopter()) && 
                    (GetAmmoCount() || !CannonRequiresSupply(-1)))
                {
                    SetTarget(uTarget);
                    SetCannonFireMode(-1, enableFire);
                    state Attacking;
                }
    }
    
    /*komenda nie wystawiana na zewnatrz*/
    command AttackOnPoint(int nX, int nY, int nZ) hidden button "translateCommandAttack" 
    {
        SetTarget(null);
        m_nTargetGx = nX;
        m_nTargetGy = nY;
        m_nTargetLz = nZ;
        SetCannonFireMode(-1, disableFire);
        state AttackingPoint;
    }
    
    //--------------------------------------------------------------------------
    command SendSupplyRequest() hidden button "translateCommandSupply" description "translateCommandSupplyDescription" hotkey priority 27
    {
        SendSupplyRequest();
    }
    
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        CallMoveInsideObject(uEntrance);
        m_nTargetGx = GetEntranceX(uEntrance);
        m_nTargetGy = GetEntranceY(uEntrance);
        m_nTargetLz = GetEntranceZ(uEntrance);
        SetCannonFireMode(-1, disableFire);
        state StartMoving;
    }
    
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    //--------------------------------------------------------------------------
    command UserOneParam0(int nMode)
    {
        m_bFindAndDestroyWalls=1;
    }
    //--------------------------------------------------------------------------
    command UserOneParam1(int nMode)
    {
        m_bFindAndDestroyWalls=0;
    }
    
    //--------------------------------------------------------------------------
 /*   command UserOneParam9(int nMode) button traceMode priority 255
    {
            if (nMode == -1)
            {
            traceMode = (traceMode + 1) % 2;
            }
            else
            {
            assert(nMode == 0);
            traceMode = nMode;
    }
    }
   */ 
    
    //--------------------------------------------------------------------------
    /*button "Attack"
    description "euhwfduihewuif"
    hotkey   // flaga ze ma reagowac na klawisz do tej komendy
    priority 7 */
}