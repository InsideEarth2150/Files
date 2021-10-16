tank "translateScriptNameTankStatic"
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
    unit m_uSpecialUnit;
        int  bFirstShoot;
    
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
        "translateCommandStateHoldPosition",
            
multi:
        "translateCommandStateMovement"
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
        
        if(nRangeMode == 0) //poza zasiegiem
        {
            //              if(traceMode)   TraceD("GoToPoint: Point not in range                               \n");
            CallMoveToPoint(m_nTargetGx, m_nTargetGy, m_nTargetLz);
            return true;
        }
        if (nRangeMode == 4) //in range
        {
            //              if(traceMode)   TraceD("GoToPoint: In range                               \n");
            if (IsMoving())
                CallStopMoving();
            return false;
        }
        if(nRangeMode == 1) //w zasiegu ale trzeba odwrocic czolg 
        {
            //              if(traceMode)   TraceD("GoToPoint: Rotating tank                               \n");
            if (IsMoving())
                CallStopMoving();
            else
                CallTurnToAngle(GetCannonAngleToPoint(0,m_nTargetGx, m_nTargetGy, m_nTargetLz));
            
            return true;
        }
        
        //w zasiegu ale zly kat beta lub cos zaslania 
        //sprobujmy dojechac do punktu polozonego o 90 stopni od aktualnej pozycji 
        //      if(traceMode)   TraceD("GoToPoint:  Side step                                   \n");
        
        // stara wersja
        //     nDx = m_nTargetGx - m_nTargetGy + GetLocationY();
        //     nDx = m_nTargetGy + m_nTargetGx - GetLocationX();
        //     CallMoveToPoint(nDx, nDy, m_nTargetLz);
        
        
        /*nDx = (m_nTargetGx - GetLocationX())/2;
        nDy = (m_nTargetGy - GetLocationY())/2;
        
          if(nDx>1)nDx=1;
          if(nDx<-1)nDx=-1;
          if(nDy>1)nDy=1;
          if(nDy<-1)nDy=-1;
          if(IsFreePoint(GetLocationX()+nDy, GetLocationY()-nDx, m_nTargetLz))
          CallMoveToPoint(GetLocationX()+nDy, GetLocationY()-nDx, m_nTargetLz);
          else
        */
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
        int nRange;
        if(traceMode)   TraceD("GTT:");
        nRangeMode = IsTargetInCannonRange(0, m_uTarget);
        nDistance = DistanceTo(m_uTarget.GetLocationX(),m_uTarget.GetLocationY());
        
        if(nRangeMode == notInRange)
        {
            //CallMoveToPoint(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
            CallMoveOneField(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
            if(traceMode)     TraceD("             \n");
            return true;
        }
        if (nRangeMode == inRangeGoodHit)
        {
            if(traceMode)   TraceD("In range. ");
            if (IsMoving())
            {
                CallStopMoving();
                if(traceMode)     TraceD("Stop!");
            }
            if(traceMode)   TraceD("             \n");
            return false;
        }
        
        if(nRangeMode == inRangeBadAngleAlpha) //w zasiegu ale trzeba odwrocic czolg 
        {
            if(traceMode)   TraceD("Rotate. ");
            if (IsMoving())
            {
                if(traceMode) TraceD("Stop! ");
                CallStopMoving();
            }
            else
            {
                if(traceMode) TraceD("CallTurnToAngle.");
                CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
            }
            if(traceMode)     TraceD("             \n");
            return true;
        }
        
        if(nRangeMode == inRangeBadAngleBeta)//w zasiegu strzalu ale zly kat beta
        {
            if(traceMode)     TraceD("Zly beta: ");
            if(nDistance<3)//odsunac sie
            {
                if(traceMode)   TraceD("od celu.");
                CallMoveToPoint(2*GetLocationX()-m_uTarget.GetLocationX(),2*GetLocationY()-m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
            }
            else
            {
                //jazda do punktu o 90stopni
                if(traceMode)   TraceD("90 stopni");
                m_nTargetGx = m_uTarget.GetLocationX();
                m_nTargetGy = m_uTarget.GetLocationY();
                m_nTargetLz = m_uTarget.GetLocationZ();
                nDx = m_nTargetGx - m_nTargetGy + GetLocationY();
                nDy = m_nTargetGy + m_nTargetGx - GetLocationX();
                CallMoveOneField(nDx, nDy, m_nTargetLz);
            }
            if(traceMode)     TraceD("             \n");
            return true;
        }
        
        //w zasiegu ale cos zaslania 
        if(nDistance<3)//odsunac sie
        {
            if(traceMode)   TraceD("Zly beta: od celu                                   \n");
            CallMoveToPoint(2*GetLocationX()-m_uTarget.GetLocationX(),2*GetLocationY()-m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
        }
        else
        {
            if(traceMode)     TraceD("Zaslania: ");
            /*  if(nDistance<6)//jazda do punktu o 90stopni
            {
            if(traceMode)   TraceD("90 stopni. ");
            m_nTargetGx = m_uTarget.GetLocationX();
            m_nTargetGy = m_uTarget.GetLocationY();
            m_nTargetLz = m_uTarget.GetLocationZ();
            nDx = m_nTargetGx - m_nTargetGy + GetLocationY();
            nDy = m_nTargetGy + m_nTargetGx - GetLocationX();
            CallMoveOneField(nDx, nDy, m_nTargetLz);
            }
            else // jazda do wroga*/
            {
                if(traceMode)   TraceD("do celu.");
                CallMoveOneField(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());
            }
        }
        /*
        //jeden krok w prawo
        nDx = (m_uTarget.GetLocationX() - GetLocationX())/2;
        nDy = (m_uTarget.GetLocationY() - GetLocationY())/2;
        
          if(nDx>1)nDx=1;
          if(nDx<-1)nDx=-1;
          if(nDy>1)nDy=1;
          if(nDy<-1)nDy=-1;
          CallMoveToPoint(GetLocationX()-nDy, GetLocationY()+nDx, m_uTarget.GetLocationZ());
        */
        if(traceMode)   TraceD("             \n");
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
            if(traceMode)   TraceD("Rotating tank                               \n");
            if (IsMoving())
            {
                if(traceMode) TraceD("CallStopMoving                               \n");
                CallStopMoving();
            }
            else
            {
                if(traceMode) TraceD("CallTurnToAngle                               \n");
                CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
            }
            return true;
        }
        return false;
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
            if(movementMode==1)//hold position
            {
                SetTarget(FindTarget(nFindTarget,findEnemyUnit,findNearestUnit,findDestinationAnyUnit));
            }
            else
            {
                SetTarget(FindClosestEnemyUnitOrBuilding(nFindTarget));
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
    //------------------------------------------------------- 
    state InPlatoonState
    {
        if(traceMode)   TraceD("IP\n");
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
    
    state Nothing
    {
        if(!IsAllowingWithdraw())AllowScriptWithdraw(true);
        if(traceMode)TraceD("N                                                 \n");
        if(InPlatoon())
        {
            SetCannonFireMode(-1, enableFire);
            return InPlatoonState;
        }
        if(GetCannonType(0)==cannonTypeBallisticRocket) return Nothing;
        
        if(movementMode==1) return HoldPosition;
        
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
        if(IsAllowingWithdraw())AllowScriptWithdraw(false);
        if(traceMode)TraceD("HP                                                 \n");
        
        if(movementMode==0) return Nothing;
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
        if( nDistance > 12)
        {
            if(traceMode)TraceD("nDistance: > 12 !!!!!                                                \n  ");
            SetTarget(null);
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
            SetCannonFireMode(-1, enableFire);
            return Moving;          
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
            FindBestTarget();
            if(!m_uTarget)
            {
                SetTarget(GetAttacker());
                ClearAttacker();
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
                SetCannonFireMode(-1, enableFire);
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                return Moving;
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
        movementMode=1;
        SetCannonFireMode(-1, disableFire);
        AllowScriptWithdraw(false);
    }
    //--------------------------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
        AllowScriptWithdraw(true);
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
            movementMode = (movementMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            movementMode = nMode;
        }
        NextCommand(0);
    }
    //--------------------------------------------------------------------------
        command HoldPosition() hidden button "translateCommandStop" hotkey
        {
            SetTarget(null);
            StopCannonFire(-1);
            m_nStayGx = GetLocationX();
            m_nStayGy = GetLocationY();
            m_nStayLz = GetLocationZ();
            movementMode = 1;
            ChangedCommandValue();
            if(IsMoving())
                    CallStopMoving();
            SetCannonFireMode(-1, disableFire);
            state Nothing;
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
    command Move(int nGx, int nGy, int nLz) button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        SetTarget(null);
        m_nStayGx = nGx;
        m_nStayGy = nGy;
        m_nStayLz = nLz;
                if(state==Froozen)
                {
                    m_nState = 3;
                }
                else
                {
                    SetCannonFireMode(-1, enableFire);
                    AllowScriptWithdraw(true);
                    CallMoveToPoint(nGx, nGy, nLz);
                    state StartMoving;
                }
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
        AllowScriptWithdraw(true);
        state Patrol;
    }
    
    
    //--------------------------------------------------------------------------
    command Escort(unit uUnit) button "translateCommandEscort" description "translateCommandEscortDescription" hotkey priority 31 
    {
        AllowScriptWithdraw(true);
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
    }
    */
    //--------------------------------------------------------------------------
    /*button "Attack"
    description "euhwfduihewuif"
    hotkey   // flaga ze ma reagowac na klawisz do tej komendy
    priority 7 */
}