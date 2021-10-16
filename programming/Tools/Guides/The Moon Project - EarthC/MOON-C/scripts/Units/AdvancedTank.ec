tank "translateScriptNameTankAdvanced"
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
    unit m_uSpecialUnit;
    
    enum lights
    {
        "translateCommandStateLightsAUTO",
        "translateCommandStateLightsON",
        "translateCommandStateLightsOFF",
multi:
        "translateCommandStateLightsMode"
    }
    
    enum movementMode
    {
        "translateCommandStateFollowEnemy",
        "translateCommandStateHoldArea",
        "translateCommandStateHoldPosition",
            
multi:
        "translateCommandStateMovement"
    }
    
    enum attackMode
    {
        "translateCommandStateFireAtWill",
        "translateCommandStateReturnfire",
        "translateCommandStateHoldFire",
multi:
        "translateCommandStateFireMode"
    }
    
    enum searchMode
    {
        "translateCommandStateNearestTarget",
        "translateCommandStateWeakestTarget",
multi:
        "translateCommandStateTargeting"
    }
    
    enum retreatMode
    {
        "translateCommandStateNoRetreat",
        "translateCommandStateRetreatNoAmmo",
        "translateCommandStateRetreatHP50",
        "translateCommandStateRetreatHP25",
multi:
        "translateCommandStateRetreatMode"
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
        
        if(nRangeMode == 0) //poza zasiegiem
        {
            CallMoveToPoint(m_nTargetGx, m_nTargetGy, m_nTargetLz);
            return true;
        }
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
        
        nDistance = DistanceTo(m_uTarget.GetLocationX(),m_uTarget.GetLocationY());
        
        if(nRangeMode == notInRange)
        {
            CallMoveToPoint(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
            return true;
        }
        if (nRangeMode == inRangeGoodHit)
        {
            if (IsMoving())
            {
                CallStopMoving();
            }
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
        
        if(nRangeMode == inRangeBadAngleBeta)//w zasiegu strzalu ale zly kat beta
        {
            if(nDistance<3)//odsunac sie
            {
                CallMoveToPoint(2*GetLocationX()-m_uTarget.GetLocationX(),2*GetLocationY()-m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
            }
            else
            {
                //jazda do punktu o 90stopni
                m_nTargetGx = m_uTarget.GetLocationX();
                m_nTargetGy = m_uTarget.GetLocationY();
                m_nTargetLz = m_uTarget.GetLocationZ();
                nDx = m_nTargetGx - m_nTargetGy + GetLocationY();
                nDy = m_nTargetGy + m_nTargetGx - GetLocationX();
                CallMoveOneField(nDx, nDy, m_nTargetLz);
            }
            return true;
        }
        
        //w zasiegu ale cos zaslania 
        if(nDistance<3)//odsunac sie
        {
            CallMoveToPoint(2*GetLocationX()-m_uTarget.GetLocationX(),2*GetLocationY()-m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
        }
        else
        {
            CallMoveToPoint(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
        }
        return true;
    }
    
    //------------------------------------------------------- 
    function int TargetInRange()
    {
        int nRangeMode;
        int nDx;
        int nDy;
        nRangeMode = IsTargetInCannonRange(0, m_uTarget);
        
        if (nRangeMode == inRangeGoodHit) 
        {
            return true;
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
        return false;
    }
    //-------------------------------------------------------
    function int EndState()
    {
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
            if(searchMode==1)//find weakest target
                SetTarget(FindTarget(nFindTarget, findEnemyUnit, findWeakestUnit, findDestinationAnyUnit));
            else //find closest target
                SetTarget(FindClosestEnemyUnitOrBuilding(nFindTarget));

            if(m_uTarget!=null && 
                movementMode==2 && 
                (IsTargetInCannonRange(0, m_uTarget)!=inRangeGoodHit))
            {
                if(!CanCannonFireToAircraft(-1))
                    SetTarget(FindTarget(nFindTarget, findEnemyUnit, findNearestUnit, findDestinationAnyUnit));
                else
                    SetTarget(FindTarget(nFindTarget, findEnemyUnit, findNearestUnit, findDestinationAnyUnit));
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
    state HoldPosition;
    state StartMoving;
    state Moving;
    state AutoAttacking;
    state Attacking;
    state AttackingPoint;
    state Patrol;
    state Escort;
    state InPlatoonState;
    state Retreat;
    //------------------------------------------------------- 
    state Retreat
    {
        if(IsAllowingWithdraw())AllowScriptWithdraw(true);
        if(!m_nSpecialCounter)
        {
            SetTargetObject(null);
            m_uTarget = FindClosestEnemy();
            m_nSpecialCounter = (m_nSpecialCounter+1)%16;
        }
        else
        {
            if(IsMoving())
                m_nSpecialCounter = (m_nSpecialCounter+1)%16;
            else
                m_nSpecialCounter = 0;
            if(traceMode)TraceD("R                                                 \n");
            return Retreat;
        }
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
        return Retreat;
    }
    
    
    //------------------------------------------------------- 
    state InPlatoonState
    {
        if(!IsAllowingWithdraw())AllowScriptWithdraw(true);
        if(traceMode)   TraceD("IP\n");
        if(!InPlatoon()) 
        {
            SetLightsMode(lights);
            SetCannonFireMode(-1, disableFire);
            return Nothing;
        }
        return InPlatoonState;
    }
    //------------------------------------------------------- 
    
    state Nothing
    {
        if(traceMode)TraceD("N                                                 \n");
        if(!IsAllowingWithdraw())AllowScriptWithdraw(true);
        if(InPlatoon())
        {
            SetCannonFireMode(-1, enableFire);
            return InPlatoonState;
        }
        if(GetCannonType(0)==cannonTypeBallisticRocket) return Nothing;
        
        if(movementMode==2) return HoldPosition;
        
        if(attackMode==2)//hold fire
            return Nothing;
        
        if (attackMode == 0)//Fire at will
            FindBestTarget();
        
        if(!m_uTarget)
        {
            SetTarget(GetAttacker());
            ClearAttacker();
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
    state HoldPosition
    {
        if(traceMode)TraceD("HP                                                 \n");
        if(IsAllowingWithdraw())AllowScriptWithdraw(false);
        if(movementMode!=2) return Nothing;
        if(m_uTarget)
        { 
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget) || (GetCannonType(0) == cannonTypeIon && m_uTarget.IsDisabled()))
            {
                StopCannonFire(-1);
                SetTarget(null);
            }
            else
            {
                if(TargetInRange())
                {
                    if(traceMode)TraceD("HP Fire!!!                                                \n");
                    CannonFireToTarget(-2, m_uTarget, -1);
                }
                else
                    SetTarget(null);
            }
        }
        else
        {
            if(attackMode==2)//hold fire
                return HoldPosition;   
            
            if (attackMode == 0)//Fire at will
                FindBestTarget();
            
            if(!m_uTarget)
            {
                SetTarget(GetAttacker());
                ClearAttacker();
            }
        }        
        return HoldPosition;
    }
    //----------------------------------------------------
    state AutoAttacking
    {
        int nDistance;
        
        if(traceMode)TraceD("AA                                                \n");
        
        // pozostawaj w okolicach punktu
        nDistance = Distance(m_nStayGx,m_nStayGy,GetLocationX(),GetLocationY());
        if(movementMode==1 && nDistance > 8)
        {
            if(traceMode)TraceD("nDistance: > 12 !!!!!                                                \n  ");
            SetTarget(null);
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
            if(attackMode==0) SetCannonFireMode(-1, enableFire);
            return StartMoving;         
        }
        
        if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget) || (GetCannonType(0) == cannonTypeIon && m_uTarget.IsDisabled()))
        {
            StopCannonFire(-1);
            SetTarget(null);
        }
        
        if (m_uTarget)
        {
            if(!GoToTarget())
            {
                if(traceMode)TraceD("AA    Fire!!!!                                           \n");
                CannonFireToTarget(-2, m_uTarget, -1);
                return AutoAttacking;
            }
            return AutoAttacking,2;
        }
        else//target not exist
        {
            if(attackMode==0)
                FindBestTarget();
            if(!m_uTarget &&attackMode==1)
            {
                SetTarget(GetAttacker());
                ClearAttacker();
            }
            
            if (m_uTarget != null)
                return AutoAttacking;
            
            if( nDistance > 0 && movementMode==1)
            {
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                return StartMoving;                     
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
        else //target not exist or is disabled
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
        if(attackMode==0) SetCannonFireMode(-1, enableFire);
        return Moving, 20;
    }
    //--------------------------------------------------------------------------
    state Moving
    {
        if (IsMoving())
        {
            if(GetAttacker()!=null && attackMode==1)
            {
                SetTarget(GetAttacker());
                CannonFireToTarget(-2, m_uTarget, -1);
                ClearAttacker();
                m_uTarget=null;
            }
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
    state Patrol
    {
        if(m_uTarget)
        {
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget) || (GetCannonType(0) == cannonTypeIon && m_uTarget.IsDisabled()))
            {
                StopCannonFire(-1);
                SetTarget(null);
            }
            else
            {
                if(GoToTarget())
                {
                    return Patrol,2;
                }
                else
                {
                    CannonFireToTarget(-2, m_uTarget, -1);
                    return Patrol;
                }
            }
        }
        else
            FindBestTarget();
        
        if (!IsMoving())
        {
            if(m_nSpecialCounter == 1)
            {
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                m_nSpecialCounter = 0;
            }
            else
            {
                CallMoveToPoint(m_nSpecialGx, m_nSpecialGy, m_nSpecialLz);
                m_nSpecialCounter = 1;
            }
        }
        return Patrol;
    }
    //--------------------------------------------------------------------------
    state Escort
    {
        if(traceMode)TraceD("Escort                                                 \n");
        
        if(m_uTarget)
        {
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget) || (GetCannonType(0) == cannonTypeIon && m_uTarget.IsDisabled()))
            {
                StopCannonFire(-1);
                SetTarget(null);
            }
            else
            {
                if(GoToTarget())
                {
                    return Escort,2;
                }
                else
                {
                    CannonFireToTarget(-2, m_uTarget, -1);
                    return Escort;
                }
            }
        }
        else
            FindBestTarget();
        
        if(!m_uSpecialUnit.IsLive())
        {
            m_uSpecialUnit=null;
            if(IsMoving())
            {
                CallStopMoving();
                return Escort;
            }
            EndState();
            return Nothing;
        }
        
        m_nTargetGx = m_uSpecialUnit.GetLocationX()+m_nSpecialGx;
        m_nTargetGy = m_uSpecialUnit.GetLocationY()+m_nSpecialGy;
        m_nTargetLz = m_uSpecialUnit.GetLocationZ();
        if(Distance(m_nTargetGx,m_nTargetGy,GetLocationX(),GetLocationY()) > 0)
        {
            if(traceMode) TraceD("Escort: updating position                                                \n  ");
            CallMoveToPoint(m_nTargetGx, m_nTargetGy, m_nTargetLz);
            return Escort;              
        }
        else
        {
            if(IsMoving())
            {
                CallStopMoving;
                return Escort;
            }
            return Escort;
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
                if(attackMode==0) SetCannonFireMode(-1, enableFire);
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                return StartMoving;
            }
            
            if(m_nState==4)
                return Patrol;
            
            if(m_nState==5)
                return Escort;
            
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
        if (attackMode == 1 && m_uTarget==null)//Return fire
        {
            SetTarget(GetAttacker());
            CannonFireToTarget(-2, m_uTarget, -1);
        }
        if(retreatMode == 2 || retreatMode == 3)
        {
            if((GetHP()*4)<GetMaxHP())
            {
                m_nSpecialCounter=0;
                state Retreat;
            }
            if(retreatMode == 2 &&((GetHP()*2)<=GetMaxHP()))
            {
                m_nSpecialCounter=0;
                state Retreat;
            }
        }
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
        if(retreatMode == 1)
        {
            m_nSpecialCounter=0;
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
                if(attackMode!=0)//hold fire | return fire
                    return true;
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
        if(state!=Froozen) m_nState = 0;
        if(state==AttackingPoint)
            m_nState=1;
        if(state==Attacking)
            m_nState=2;
        if((state==Moving) || (state==StartMoving))
            m_nState=3;
        if(state==Patrol)
            m_nState=4;
        if(state==Escort)
            m_nState=5;
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
        m_uSpecialUnit = null;
    }
    //------------------------------------------------------- 
    event OnConvertedToNewPlayer()
    {
        StopCannonFire(-1);
        SetCannonFireMode(-1, disableFire);
        SetTarget(null);
        m_uSpecialUnit = null;
                ClearAttacker();
        state Nothing;
    }
    
    //********************************************************
    //*********** C O M M A N D S ****************************
    //********************************************************
    command Initialize()
    {
        m_nCannonsCount = GetCannonsCount();
        traceMode = 0;
        movementMode=0;
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
    command SetLights(int nMode) button lights description "translateCommandStateLightsModeDescription" hotkey priority 204
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
    command SetMovementMode(int nMode) button movementMode description "translateCommandStateMovementDescription"priority 205
    {
        if (nMode == -1)
        {
            movementMode = (movementMode + 1) % 3;
        }
        else
        {
            assert(nMode == 0);
            movementMode = nMode;
        }
        NextCommand(0);
    }
    //--------------------------------------------------------------------------
    command SetAttackMode(int nMode) button attackMode description "translateCommandStateFireModeDescription" hotkey priority 6
    {
        if (nMode == -1)
        {
            attackMode = (attackMode + 1) % 3;
        }
        else
        {
            assert(nMode == 0);
            attackMode = nMode;
        }
                if(attackMode!=0)
                {
                    SetCannonFireMode(-1, disableFire);
                    StopCannonFire(-1);
                }
    }
    //--------------------------------------------------------------------------
    command UserOneParam1(int nMode) button searchMode description "translateCommandStateTargetingDescription" priority 8
    {
        if (nMode == -1)
        {
            searchMode = (searchMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            searchMode = nMode;
        }
    }
    //--------------------------------------------------------------------------
    command UserOneParam2(int nMode) button retreatMode description "translateCommandStateRetreatModeDescription" priority 12
    {
        if (nMode == -1)
        {
            retreatMode = (retreatMode + 1) % 4;
        }
        else
        {
            assert(nMode == 0);
            retreatMode = nMode;
        }
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
        state Nothing;
    }
    //--------------------------------------------------------------------------
        command HoldPosition() hidden button "translateCommandHoldPosition" description "translateCommandStopDescription" hotkey priority 20
        {
            SetTarget(null);
            StopCannonFire(-1);
            m_nStayGx = GetLocationX();
            m_nStayGy = GetLocationY();
            m_nStayLz = GetLocationZ();
            if(IsMoving())
                    CallStopMoving();
            movementMode=2;
            SetCannonFireMode(-1, disableFire);
            ChangedCommandValue();
            state Nothing;
        }
    //--------------------------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        SetTarget(null);
        m_nStayGx = nGx;
        m_nStayGy = nGy;
        m_nStayLz = nLz;
        if(attackMode==0) SetCannonFireMode(-1, enableFire);
        CallMoveToPoint(nGx, nGy, nLz);
        state StartMoving;
    }
        //--------------------------------------------------------------------------
    command Attack(unit uTarget) button "translateCommandAttack" description "translateCommandAttackDescription" hotkey priority 22
    {
        SetTarget(uTarget);
                bFirstShoot=true;
        if(attackMode==0) SetCannonFireMode(-1, enableFire);
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
    command UserNoParam0() button "translateCommandRetreat" description "translateCommandRetreatDescription" hotkey priority 25
    {
        m_nSpecialCounter=0;
        state Retreat;
    }
    
    //--------------------------------------------------------------------------
    command SendSupplyRequest() button "translateCommandSupply" description "translateCommandSupplyDescription" hotkey priority 27
    {
        SendSupplyRequest();
    }
    //--------------------------------------------------------------------------
    command Patrol(int nGx, int nGy, int nLz) button "translateCommandPatrol" description "translateCommandPatrolDescription" hotkey priority 29
    {
        m_nSpecialGx = nGx;
        m_nSpecialGy = nGy;
        m_nSpecialLz = nLz;
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        CallMoveToPoint(nGx, nGy, nLz);
        m_nSpecialCounter = 1;
        SetCannonFireMode(-1, disableFire);
        state Patrol;
    }
    
    
    //--------------------------------------------------------------------------
    command Escort(unit uUnit) button "translateCommandEscort" description "translateCommandEscortDescription" hotkey priority 31 
    {
        m_uSpecialUnit=uUnit;
        m_nSpecialGx=GetLocationX()-m_uSpecialUnit.GetLocationX();
        m_nSpecialGy=GetLocationY()-m_uSpecialUnit.GetLocationY();
        if(m_nSpecialGx > 2) m_nSpecialGx=2;
        if(m_nSpecialGx < -2) m_nSpecialGx=-2;
        if(m_nSpecialGy > 2) m_nSpecialGy=2;
        if(m_nSpecialGy < -2) m_nSpecialGy=-2;
        state Escort;
    }
    
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
    /*  command UserOneParam9(int nMode) button traceMode priority 255
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
    }*/
    
    //--------------------------------------------------------------------------
}
