tank "translateScriptNameTankSimple"
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
    int  m_nSpecialGx; //Patrol point , escort
    int  m_nSpecialGy;
    int  m_nSpecialLz;
    int  m_nSpecialCounter;
        int  m_nState;
        int  bFirstShoot;
    
    enum lights
    {
        "translateCommandStateLightsAUTO",
        "translateCommandStateLightsON",
        "translateCommandStateLightsOFF",
multi:
        "translateCommandStateLightsMode"
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
        int nDx;
        int nDy;
        int nDistance;
        nRangeMode = IsTargetInCannonRange(0, m_uTarget);
        
        if (nRangeMode == inRangeGoodHit)
        {
            if (IsMoving())
                CallStopMoving();
            return false;
        }
        
        if(nRangeMode == inRangeBadAngleAlpha) //w zasiegu ale trzeba odwrocic czolg 
        {
            if (IsMoving())
            {
                CallStopMoving();
            }
            else
            {
                CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
            }
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
        int nTargetsFlag;
        unit newTarget;
        int nFindTarget;
        
        if(GetCannonType(0) != cannonTypeIon)
        {
            if(GetCannonType(0) == cannonTypeLaser)
            {
                SetTarget(FindClosestEnemyUnitOrBuilding(findTargetWaterUnit | findTargetNormalUnit));
            }
            else
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
                //SetTarget(FindTarget(findTargetAnyUnit,findEnemyUnit,findNearestUnit,findDestinationAnyUnit));
                SetTarget(null);
                BuildTargetsArray(nFindTarget, findEnemyUnit,findDestinationAnyUnit);
                SortFoundTargetsArray();
                nTargetsCount=GetTargetsCount();
                if(nTargetsCount==0) return false;
                
                StartEnumTargetsArray();
                for(i=0;i<nTargetsCount;i=i+1)
                {
                    newTarget = GetNextTarget();
                    if(!i)SetTarget(newTarget);
                    if(IsTargetInCannonRange(0, m_uTarget)==inRangeGoodHit)
                    {
                        EndEnumTargetsArray();
                        SetTarget(newTarget);
                        return true;
                    }
                }
                EndEnumTargetsArray();
                return true;
            }
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
    state StartMoving;
    state Moving;
    state Attacking;
    state AttackingPoint;
    //------------------------------------------------------- 
    state InPlatoonState
    {
        if(IsAllowingWithdraw())AllowScriptWithdraw(true);
        if(!InPlatoon()) 
        {
            SetLightsMode(lights);
            SetCannonFireMode(-1, disableFire);
            return Nothing;
        }
        return InPlatoonState;
    }
    //------------------------------------------------------- 
    
    state Nothing // w tym czolgu dziala on jak HoldPosition
    {
        int nRangeMode;
        
        if(IsAllowingWithdraw())AllowScriptWithdraw(false);
        if(InPlatoon())
        {
            SetCannonFireMode(-1, enableFire);
            return InPlatoonState;
        }
        
        if(GetCannonType(0)==cannonTypeBallisticRocket) return Nothing;
        if(m_uTarget)
        { 
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget) || (GetCannonType(0) == cannonTypeIon && m_uTarget.IsDisabled()))
            {
                StopCannonFire(-1);
                SetTarget(null);
            }
            else
            {
                nRangeMode = IsTargetInCannonRange(0, m_uTarget);
                if(nRangeMode == inRangeGoodHit) 
                {
                    CannonFireToTarget(-2, m_uTarget, -1);
                    return Nothing,40;
                }
                else if(nRangeMode == inRangeBadAngleAlpha) //w zasiegu ale trzeba odwrocic czolg 
                    CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
                else
                    SetTarget(null);
            }
            return Nothing,5;
        }
        else
        {
            FindBestTarget();
            if(!m_uTarget)
            {
                SetTarget(GetAttacker());
                ClearAttacker();
            }
        }        
        return Nothing;
    }
    //--------------------------------------------------------------------------
    state AttackingPoint
    {
        if(GoToPoint())
        {
            return AttackingPoint,5;
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
        if (m_uTarget.IsLive() && 
                    (GetCannonType(0) != cannonTypeIon || !m_uTarget.IsDisabled() || bFirstShoot))
        {
            if(GoToTarget())
            {
                return Attacking,2;
            }
            else
            {
                                bFirstShoot=false;
                CannonFireToTarget(-1, m_uTarget, -1);
                                return Attacking;
            }
        }
        else //target not exist
        {
            SetTarget(null);
                        StopCannonFire(-1);
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
        if (IsMoving())
        {
            return Moving;
        }
        else
        {
            EndState(); 
            return Nothing;
        }
    }
    //------------------------------------------------------- 
    state Froozen
    {
        if (IsFroozen() || IsMoving())
        {
            state Froozen;
        }
        else
        {
            //!!wrocic do tego co robilismy
            if(m_nState==1)
                return AttackingPoint;
            
            if(m_nState==2)
                return Attacking;
            
            if(m_nState==3)
            {
                SetCannonFireMode(-1, enableFire);
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                return Moving;
            }
            
            if(m_nState==6)
                return InPlatoonState;
            
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
        true;
    }
    //------------------------------------------------------- 
    event OnCannonLowAmmo(int nCannonNum)
    {
        SendSupplyRequest();
        true;
    }
    //------------------------------------------------------- 
    event OnCannonNoAmmo(int nCannonNum)
    {
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
        //XXXMD
        false;
    }
    //------------------------------------------------------- 
    event OnFreezeForSupplyOrRepair(int nFreezeTicks)
    {
        if(state!=Froozen) m_nState = 0;
        if(state==AttackingPoint)
            m_nState=1;
        if(state==Attacking)
            m_nState=2;
        if((state==Moving) || (state==StartMoving))
            m_nState=3;
        if(state==InPlatoonState)
            m_nState=6;
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
    }
    //------------------------------------------------------- 
    event OnConvertedToNewPlayer()
    {
        StopCannonFire(-1);
        SetCannonFireMode(-1, disableFire);
        SetTarget(null);
                ClearAttacker();
        state Nothing;
    }
    
    //********************************************************
    //*********** C O M M A N D S ****************************
    //********************************************************
    command Initialize()
    {
        m_nCannonsCount = GetCannonsCount();
        SetCannonFireMode(-1, disableFire);
        AllowScriptWithdraw(true);
    }
    //--------------------------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
        SetTarget(null);
        AllowScriptWithdraw(true);
    }
    //--------------------------------------------------------------------------
    command SetLights(int nMode) hidden button lights hotkey priority 204
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
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        SetTarget(null);
        StopCannonFire(-1);
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        if(IsMoving())
            CallStopMoving();
        SetCannonFireMode(-1, disableFire);
        AllowScriptWithdraw(true);
        state Nothing;
    }
        //--------------------------------------------------------------------------
        command HoldPosition() hidden button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
        {
            SetTarget(null);
            StopCannonFire(-1);
            m_nStayGx = GetLocationX();
            m_nStayGy = GetLocationY();
            m_nStayLz = GetLocationZ();
            if(IsMoving())
                    CallStopMoving();
            SetCannonFireMode(-1, disableFire);
            AllowScriptWithdraw(true);
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
        AllowScriptWithdraw(true);
        CallMoveToPoint(nGx, nGy, nLz);
        state StartMoving;
    }
        //--------------------------------------------------------------------------
    command Attack(unit uTarget) button "translateCommandAttack" description "translateCommandAttackDescription" hotkey priority 22
    {
        SetTarget(uTarget);
                bFirstShoot=true;
        SetCannonFireMode(-1, enableFire);
        AllowScriptWithdraw(true);
                if(state==Froozen)
                {
                    m_nState = 2;
                }
                else
                {
                    
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
              AllowScriptWithdraw(true);
            SetCannonFireMode(-1, disableFire);
                if(state==Froozen)
                {
                    m_nState = 1;
                }
                else
                {
            state AttackingPoint;
                }
    }    
        //--------------------------------------------------------------------------
    command SendSupplyRequest() hidden button "translateCommandSupply" description "translateCommandSupplyDescription" hotkey priority 27
    {
        SendSupplyRequest();
    }
    //--------------------------------------------------------------------------
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        AllowScriptWithdraw(true);
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
    
    //translateCommandToAdvancedMode
    //translateCommandToSimpleMode
    
    //--------------------------------------------------------------------------
    /*button "Attack"
    description "euhwfduihewuif"
    hotkey   // flaga ze ma reagowac na klawisz do tej komendy
    priority 7 */
    
}