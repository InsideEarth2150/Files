platoon "translateDefaultPlatoon"
{
    consts
    {
        disableFire=0;
        enableFire=1;
    }
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
    
    enum movementMode
    {
        "translateCommandStateFollowEnemy",
        "translateCommandStateHoldPosition",
            
multi:
        "translateCommandStateMovement"
    }
    
    enum platoonType
    {
        "translateCommandPlatoonNormal",
        "translateCommandPlatoonDefensive",
            
multi:
        "translateCommandPlatoonType"
    }
    
    unit m_uTarget;
    int  m_nTargetGx;
    int  m_nTargetGy;
    int  m_nTargetLz;
    
    
    int  bAuto;
    int  m_bFindAndDestroyWalls;
    int  KeepFormationCounter;
    
    function int GoToPoint()
    {
        int nRangeMode;
        nRangeMode = IsPointInCannonRange(0,0,m_nTargetGx, m_nTargetGy, m_nTargetLz);
        
        if (nRangeMode == 4) //in range
        {
            if (IsMoving())
                CallStopMoving();
            return false;
        }
        CallMoveToPoint(m_nTargetGx, m_nTargetGy, m_nTargetLz);
        return true;
    }
    
    //------------------------------------------------------- 
    function int GoToTarget()
    {
        int nRangeMode;
        int i;
        for(i=0;i<GetUnitsCount();i=i+1)
        {
            nRangeMode = IsTargetInCannonRange(i,0, m_uTarget);
            if (nRangeMode != notInRange)
            {
                SetLeader(i);
                if (IsMoving())
                    CallStopMoving();
                return false;
            }
        }
        CallMoveToPoint(m_uTarget.GetLocationX(), m_uTarget.GetLocationY(), m_uTarget.GetLocationZ());      
        return true;
    }
    //------------------------------------------------------- 
    function int PrepareEnter(unit uEntrance)
    {
        int i;
        punit member;
        EnableFeatures(platoonFreeUnits,true);
        for(i=0;i<GetUnitsCount();i=i+1)
        {
            member = GetUnit(i);
            member.CommandEnter(uEntrance);
        }
        if (GetType() == typeHelicopters)
        {
            //musimy sie juz teraz skasowac bo inaczej nie da sie wleciec
            Dispose();
        }
    }
    //------------------------------------------------------- 
    function int PrepareAttack(unit uTarget)
    {
        int i;
        punit member;
        EnableFeatures(platoonFreeUnits,true);
        for(i=0;i<GetUnitsCount();i=i+1)
        {
            member = GetUnit(i);
            member.CommandAttack(uTarget);
        }
    }
    //------------------------------------------------------- 
    function int EndAttack()
    {
        int i;
        punit member;
        EnableFeatures(platoonFreeUnits,false);
        for(i=0;i<GetUnitsCount();i=i+1)
        {
            member=GetUnit(i);
            member.CommandStop();
        }
    }
    //------------------------------------------------------- 
    function int PrepareMove(int x,int y)
    {
        int i;
        punit member;
        EnableFeatures(platoonFreeUnits,true);
        for(i=0;i<GetUnitsCount();i=i+1)
        {
            member = GetUnit(i);
            member.CommandMove(x,y,0);
        }
    }
    //------------------------------------------------------- 
    function int PrepareStop()
    {
        int i;
        punit member;
        EnableFeatures(platoonFreeUnits,true);
        for(i=0;i<GetUnitsCount();i=i+1)
        {
            member = GetUnit(i);
            member.CommandStop();
        }
    }
    
    //------------------------------------------------------- 
    function int EndState()
    {
        NextCommand(1);
    }
    //********************************************************
    //************* S T A T E S ******************************
    //********************************************************
    state FirstState;
    state Nothing;
    state StartMoving;
    state Moving;
    state Attacking;
    state AttackingPoint;
    //------------------------------------------------------- 
    state FirstState //pluton jest w tym stanie dopuki nie zobaczy pierwszego wroga w tym stanie rozgladaja sie wszysy bo pluton moze byc rozproszony
    {
        int i;
        int nFindTarget;

        if(traceMode)   TraceD("F");
        if(movementMode==1)
        {
            if(traceMode)     TraceD("->F mm=1                    \n");
            return FirstState,20;
        }
        if(traceMode)   TraceD(".");
        
        //m_uTarget = GetAttacker(-1);
        //ClearAttacker(-1);
        
        if(traceMode)   TraceD(".");
        if(!m_uTarget)
        {
            for(i=0;i<GetUnitsCount() && !m_uTarget;i=i+1)
            {
                nFindTarget = 0;
                if (CanCannonFireToAircraft(i, -1))
                {
                    nFindTarget = findTargetFlyingUnit;
                }
                if (CanCannonFireToGround(i, -1))
                {
                    if (GetCannonType(i,0) == cannonTypeEarthquake)
                    {
                        nFindTarget = nFindTarget | findTargetBuildingUnit;
                    }
                    else
                    {
                        nFindTarget = nFindTarget | findTargetNormalUnit | findTargetWaterUnit | findTargetBuildingUnit;
                    }
                }
                m_uTarget = FindTarget(i,nFindTarget,findEnemyUnit,findNearestUnit,findDestinationAnyUnit);
                if (m_uTarget != null) SetLeader(i);
            }
        }
        if(traceMode)   TraceD(".");
        if (m_uTarget != null)
        {
            if(traceMode)     TraceD("-> A                        \n");
            bAuto=true;
            return Attacking;
        }
        if(traceMode)   TraceD(".                             \n");
        return FirstState,20;
    }
    //------------------------------------------------------- 
    state Nothing
    {
        int nFindTarget;

        if(traceMode)   TraceD("N");
        if(movementMode==1)
        {
            if(traceMode)     TraceD("->N mm=1                    \n");
            return Nothing,20;
        }
        if(traceMode)   TraceD(".");
        m_uTarget = GetAttacker(-1);
        ClearAttacker(-1);
        if(traceMode)   TraceD(".");
        if(!m_uTarget)
        {
            if(traceMode)     TraceD("  FT");
            nFindTarget = 0;
            if (CanCannonFireToAircraft(0, -1))
            {
                nFindTarget = findTargetFlyingUnit;
            }
            if (CanCannonFireToGround(0, -1))
            {
                if (GetCannonType(0,0) == cannonTypeEarthquake)
                {
                    nFindTarget = nFindTarget | findTargetBuildingUnit;
                }
                else
                {
                    nFindTarget = nFindTarget | findTargetNormalUnit | findTargetWaterUnit | findTargetBuildingUnit;
                    if (m_bFindAndDestroyWalls)
                    {
                        nFindTarget = nFindTarget | findTargetWall;
                    }
                }
            }
            m_uTarget = FindTarget(0,nFindTarget,findEnemyUnit,findNearestUnit,findDestinationAnyUnit);
        }
        if(traceMode)   TraceD(".");
        if (m_uTarget != null)
        {
            if(traceMode)     TraceD("-> A                        \n");
            bAuto=true;
            return Attacking;
        }
        if(traceMode)   TraceD(".                             \n");
        return Nothing,20;
    }
    //--------------------------------------------------------------------------
    state StartMoving
    {
        return Moving, 20;
    }
    //--------------------------------------------------------------------------
    state Moving
    {
        if(traceMode)   TraceD("M");
        if (IsMoving())
        {
            if(traceMode)     TraceD("                             \n");
            return Moving;
        }
        else
        {
            if(traceMode)     TraceD("-stop                             \n");
            EndState(); 
            return Nothing;
        }
    }
    //--------------------------------------------------------------------------
    state AttackingPoint
    {
        if(traceMode)   TraceD("AP                       \n");
        if(GoToPoint())
        {
            return AttackingPoint;
        }
        else
        {
            CannonFireGround(-1,-1, m_nTargetGx, m_nTargetGy, m_nTargetLz, 1);
            return AttackingPoint;
        }
    }
    //----------------------------------------------------
    
    state Attacking
    {
        if(!bAuto)
        {
            if (m_uTarget.IsLive())
                        {
                                PrepareAttack(m_uTarget);
                return Attacking,60;
                        }
            EndAttack();
            EndState();
            return Nothing;
        }
        //--auto attack
        if(traceMode)   TraceD("A");
        if (m_uTarget.IsLive())
        {
            if(bAuto && DistanceTo(m_uTarget.GetLocationX(),m_uTarget.GetLocationY())>22)
            {
                if(traceMode)   TraceD("- out of distance                            \n");
                m_uTarget=null;
                return Nothing;
            }
            if(GoToTarget())
            {
                if(traceMode)   TraceD("                             \n");
                return Attacking;
            }
            else
            {
                if(traceMode)   TraceD("- fire                             \n");
                CannonFireToTarget(-1,-1, m_uTarget, -1);
                return Attacking,60;
            }
        }
        else //target not exist
        {
            m_uTarget=null;
            if (IsMoving())
            {
                if(traceMode)   TraceD("-stop");
                CallStopMoving();
            }
            if(traceMode)     TraceD("-killed -> N                             \n");
            EndState();
            return Nothing;
        }
    }
    
    //--------------------------------------------------------------------------
    state Entering
    {
        return Entering,60;
    }
    //--------------------------------------------------------------------------
    state Frozen
    {
        if (IsFrozen())
        {
            state Frozen;
        }
        else
        {
            state Nothing;
        }
    }
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //********************************************************
    //************* C O M M A N D S S ************************
    //********************************************************
    
    //--------------------------------------------------------------------------
    command Initialize()
    {
        bAuto=false;
        traceMode = 0;
        movementMode = 1;
        m_bFindAndDestroyWalls=0;
        SetCannonFireMode(-1,-1, enableFire);
        EnableFeatures(platoonHQDefense,false);
        EnableFeatures(platoonKeepFormation,true);
    }
    //--------------------------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
        m_uTarget = null;
    }
    
    //--------------------------------------------------------------------------
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        m_uTarget = null;
        SetCannonFireMode(-1,-1, enableFire);
        EndAttack();
        CallStopMoving();
        EnableFeatures(platoonFreeUnits,false);
        if(GetType()==typeHelicopters) PrepareStop();
        state Nothing;
    }
    //--------------------------------------------------------------------------
    command HoldPosition() hidden button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        m_uTarget = null;
        SetCannonFireMode(-1,-1, enableFire);
        EndAttack();
        CallStopMoving();
                movementMode = 1;
        EnableFeatures(platoonFreeUnits,false);
        if(GetType()==typeHelicopters) PrepareStop();
                ChangedCommandValue();
        state Nothing;
    }

    //--------------------------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) hidden button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        EndAttack();
        m_uTarget = null;
        SetCannonFireMode(-1,-1, enableFire);
        CallMoveToPoint(nGx, nGy, nLz);
        m_nTargetGx = nGx;
        m_nTargetGy = nGy;
        m_nTargetLz = nLz;
        EnableFeatures(platoonFreeUnits,false);
        if(GetType()==typeHelicopters) PrepareMove(nGx,nGy);
        state StartMoving;
    }
    //--------------------------------------------------------------------------
    command Attack(unit uTarget) button "translateCommandAttack" description "translateCommandAttackDescription" hotkey priority 22
    {
        bAuto=false;
        m_uTarget = uTarget;
        SetCannonFireMode(-1,-1, enableFire);
        PrepareAttack(uTarget);
        state Attacking;
    }
    //--------------------------------------------------------------------------
    /*komenda nie wystawiana na zewnatrz*/
    command AttackOnPoint(int nX, int nY, int nZ) hidden button "translateCommandAttack" 
    {
        bAuto=false;
        m_uTarget = null;
        m_nTargetGx = nX;
        m_nTargetGy = nY;
        m_nTargetLz = nZ;
        state AttackingPoint;
    }
    //--------------------------------------------------------------------------
    command SendSupplyRequest() button "translateCommandSupply" description "translateCommandSupplyDescription" hotkey priority 27
    {
        SendSupplyRequest(-1);
    }
    //--------------------------------------------------------------------------
    command RotateRigth()  button "translateCommandPlatoonTurnRight" description "translateCommandPlatoonTurnRightDescription" hotkey priority 30
    {
        EndAttack();
        Turn(64);
        KeepFormationCounter = GetUnitsCount();
        if(!IsMoving())CallStopMoving();
    }
    //--------------------------------------------------------------------------
    command RotateLeft() button "translateCommandPlatoonTurnLeft" description "translateCommandPlatoonTurnLeftDescription" hotkey priority 31
    {
        EndAttack();
        Turn(-64);
        KeepFormationCounter = GetUnitsCount();
        if(!IsMoving())CallStopMoving();
    }
    //--------------------------------------------------------------------------
    command UserNoParam2() button "translateCommandPlatoonFormLine" description "translateCommandPlatoonFormLineDescription" hotkey priority 32
    {
        int i;
        EndAttack();
        for(i=1;i<GetUnitsCount();i=i+1)
        {
            if(i%2)
                SetPosition(i,(i/2)+1,0);
            else
                SetPosition(i,-(i/2),0);
        }
        KeepFormationCounter = GetUnitsCount();
        if(!IsMoving())CallStopMoving();
    }
    //--------------------------------------------------------------------------
    command UserNoParam3() button "translateCommandPlatoonFormSquare" description "translateCommandPlatoonFormSquareDescription" hotkey priority 33
    {
        int i;
        int sqrt;
        EndAttack();
        //posortowac wedlug HP
        sqrt=1;
        while(sqrt*sqrt<GetUnitsCount())
            sqrt=sqrt+1;
        
        for(i=1;i<GetUnitsCount();i=i+1)
        {
            SetPosition(i,i%sqrt,i/sqrt);
        }
        if(!IsMoving())CallStopMoving();
    }
    //--------------------------------------------------------------------------
    command UserOneParam2(int nMode) button platoonType description "translateCommandPlatoonTypeDescription" hotkey priority 40
    {
        if (nMode == -1)
        {
            platoonType = (platoonType + 1) % 2;
        }
        else
        {
            platoonType = nMode;
        }
        EnableFeatures(platoonHQDefense,platoonType);
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
        SetLightsMode(-1,lights);
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
    command AddUnitToPlatoon(unit uUnit) button "translateCommandPlatoonAddUnit" description "translateCommandPlatoonAddUnitDescription" hotkey priority 220
    {
        AddUnitToPlatoon(uUnit);
        SetLightsMode(-1,lights);
        NextCommand(1);
    }
    //--------------------------------------------------------------------------
    command RemoveUnitFromPlatoon(unit uUnit) button "translateCommandPlatoonRemoveUnit" description "translateCommandPlatoonRemoveUnitDescription" hotkey priority 222
    {
        RemoveUnitFromPlatoon(uUnit);
        NextCommand(1);
    }
    //--------------------------------------------------------------------------
    command DisposePlatoon() button "translateCommandPlatoonDispose" description "translateCommandPlatoonDisposeDescription" hotkey priority 224
    {
        Dispose();
    }
    //--------------------------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    //--------------------------------------------------------------------------
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        EndAttack();
        m_uTarget = null;
        SetCannonFireMode(-1,-1, enableFire);
        PrepareEnter(uEntrance);
        state Entering;
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
}