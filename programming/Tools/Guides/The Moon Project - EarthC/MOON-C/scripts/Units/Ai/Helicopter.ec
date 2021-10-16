aircraft "translateScriptNameAircraft"
{
    consts
    {
        nonAttack=0;
        movingOnPosition=1;
        attacking=2;
        evacuating=3;
        attackRange=7;
        
        disableFire=0;
        findTargetWaterUnit         = 1;
        findTargetFlyingUnit        = 2;
        findTargetNormalUnit        = 4;
        findTargetBuildingUnit  = 8;
        findTargetAnyUnit           = 15;
        
        //typ rasy (jakich IFF'ow szukamy
        findEnemyUnit           = 1;
        //kryterium szukania
        findNearestUnit         = 1;
        findWeakestUnit         = 2;
        //typ szukanego obiektu
        findDestinationAnyUnit          = 15;
        //IsInRange
        notInRange = 0;//poza zasiegiem (za duza odleglosc)
        inRangeBadAngleAlpha = 1;//w zasiegu strzalu ale zly kat alpha trzeba obrocic podwozie
        inRangeBadAngleBeta = 2;//w zasiegu strzalu ale zly kat beta
        inRangeBadHit = 3; //w zasiegu strzalu ale nie mozna trafic (cos zaslania)
        inRangeGoodHit = 4;
    }
    unit m_uTarget;
    int  m_nTargetGx;
    int  m_nTargetGy;
    int  m_nTargetLz;
    int  m_nStayGx;
    int  m_nStayGy;
    int  m_nStayLz;
    int  m_nAttackGx;
    int  m_nAttackGy;
    int  m_nAttackPhase;
    int  m_nSpecialGx; //Patrol point , escort
    int  m_nSpecialGy;
    int  m_nSpecialLz;
    int  m_nSpecialCounter;
    unit m_uSpecialUnit;
    int  m_nState;
    int  m_bNeedReload;
    
    
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
    
    enum attackMode 
    {
        "translateCommandStateDynamicAttack",
        "translateCommandStateStaticAttack",
multi:
        "translateCommandStateAttackMode"
    }
    
    enum traceMode
    {
        "translateCommandStateTraceOFF",
        "translateCommandStateTraceON",
multi:
        "translateCommandStateTraceMode"
    }
    
    state Nothing;
    state HoldPosition;
    state StartMoving;
    state Moving;
    state AutoAttacking;
    state Attacking;
    state AttackingPoint;
    state Patrol;
    state Escort;
    //for flyables
    state MovingForGetSupply;
    state GettingSupply;
    
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
    function int FindBestTarget()
    {
        int nFindTarget;

        nFindTarget = 0;
        if (CanCannonFireToAircraft(0))
        {
            nFindTarget = findTargetFlyingUnit;
        }
        if (CanCannonFireToGround(0))
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
    }
    //------------------------------------------------------- 
    function int AttackRun(int bAttackOnPoint)
    {
        int nRangeMode;
        int nDx;
        int nDy;
        int nDxAbs;
        int nDyAbs;
        int nDistance;
        int nR;
        
        if(attackMode==1)//position attack
        {
            if(GetCannonType(0)==cannonTypeBomb)//bombowiec
            {
                if(traceMode)   TraceD("bombowiec                                                  \n");
                if(GetLocationX()==m_nTargetGx && GetLocationY()==m_nTargetGy)//nad celem
                {
                    if (IsMoving())
                    {
                        if(traceMode) TraceD("CallStopMoving                         \n");
                        CallStopMoving();
                    }
                    return true;
                }
                else
                {
                    if(traceMode)   TraceD("GoToTarget: Target not in range                               \n");
                    CallMoveToPoint(m_nTargetGx,m_nTargetGy,0);
                    return false;
                }
            }//--- koniec bombowca
            
            if(bAttackOnPoint)
                nRangeMode = IsPointInCannonRange(0,m_nTargetGx,m_nTargetGy,m_nTargetLz);
            else
                nRangeMode = IsTargetInCannonRange(0, m_uTarget);
            
            if (nRangeMode == inRangeGoodHit)
            {
            /*if(traceMode) TraceD("In range                         \n");
            if (IsMoving())
            {
            if(traceMode) TraceD("CallStopMoving                         \n");
            CallStopMoving();
            }*/
                return true;
            }
            
            if(nRangeMode == inRangeBadAngleAlpha) //w zasiegu ale trzeba odwrocic czolg 
            {
                if(traceMode)     TraceD("Rotating tank:");
                if (IsMoving())
                {
                    
                    if(traceMode) TraceD("CallStopMoving                         \n");
                    CallStopMoving();
                }
                else
                {
                    if(traceMode) TraceD("CallTurnToAngle                         \n");
                    if(bAttackOnPoint)
                        CallTurnToAngle(GetCannonAngleToPoint(0,m_nTargetGx,m_nTargetGy,m_nTargetLz));
                    else
                        CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
                }
                return false;
            }
            
            if(nRangeMode == inRangeBadHit) 
            {
                if(traceMode) TraceD("Zaslanianie                         \n");
                nDx = m_nTargetGx - m_nTargetGy + GetLocationY();
                nDy = m_nTargetGy + m_nTargetGx - GetLocationX();
                CallMoveLowToPoint(nDx, nDy, 0);
                //CallTurnToAngle(GetCannonAngleToPoint(0,m_nTargetGx,m_nTargetGy,m_nTargetLz));
                return true;
            }
            if(nRangeMode == inRangeBadAngleBeta) 
            {
                if(traceMode) TraceD("Zla beta                         \n");
                if(GetLocationX()==m_uTarget.GetLocationX() && GetLocationX()==m_uTarget.GetLocationX())
                    CallMoveToPoint(GetLocationX()+3,GetLocationY(), 0);
                else
                    CallMoveToPoint(2*GetLocationX()-m_uTarget.GetLocationX(),2*GetLocationY()-m_uTarget.GetLocationY(), 0);
                return true;
            }
            nDistance = DistanceTo(m_nTargetGx,m_nTargetGy);
            if(!nDistance) {nDistance=1;nDx=1;}//gdy stoimy nad celem
            nDx = GetLocationX()-m_nTargetGx;
            nDy = GetLocationY()-m_nTargetGy;
            CallMoveLowToPoint(m_nTargetGx+(((GetCannonShootRange(0)-1)*nDx)/nDistance),m_nTargetGy+(((GetCannonShootRange(0)-1)*nDy)/nDistance),0);
            if(traceMode)   
            {
                TraceD("Target not in range dist=");
                TraceD(nDistance);
                TraceD(",  rMode=");
                TraceD(nRangeMode);
                TraceD("                          \n");
            }
            return false;
        }
        
        if(m_nAttackPhase==nonAttack)
        {
            if(traceMode)     TraceD("nonAttack                              \n");
            nDx=GetLocationX()-m_nTargetGx;
            nDy=GetLocationY()-m_nTargetGy;
            
            if(nDx<0){nDxAbs=-nDx;nDx=-attackRange;}
            else {nDxAbs=nDx;nDx=attackRange;}
            if(nDy<0) {nDyAbs=-nDy;nDy=-attackRange;}
            else {nDyAbs=nDy;nDy=attackRange;}
            
            if(nDyAbs<nDxAbs)nDy=0;
            else nDx=0;
            
            m_nAttackGx = m_nTargetGx+nDx;
            m_nAttackGy = m_nTargetGy+nDy;
            
            CallMoveToPoint(m_nAttackGx, m_nAttackGy, 0);
            m_nAttackPhase = movingOnPosition;
            return false;
        }
        if(m_nAttackPhase==movingOnPosition)
        {
            if(traceMode)     TraceD("movingOnPosition                              \n");
            if(!IsMoving() || (m_nAttackGx==GetLocationX()&& m_nAttackGy==GetLocationY()))
            {
                CallMoveLowToPoint(2*m_nTargetGx - m_nAttackGx, 2*m_nTargetGy - m_nAttackGy, 0);
                m_nAttackPhase=attacking;
            }
            return false;
        }
        if(m_nAttackPhase==attacking)
        {
            if(traceMode)     TraceD("attacking: ");
            nDistance = Distance(m_nAttackGx,m_nAttackGy,GetLocationX(),GetLocationY());
            if(traceMode) {   TraceD(nDistance);TraceD("                \n");}
            if((GetCannonType(0)!=cannonTypeBomb && nDistance>4) || nDistance>8)
            {
                nDx = (m_nTargetGx - m_nAttackGx);
                nDy = (m_nTargetGy - m_nAttackGy);
                m_nAttackGx = m_nTargetGx+nDy;
                m_nAttackGy = m_nTargetGy-nDx;
                m_nAttackPhase=movingOnPosition;//evacuating;
                CallMoveToPoint(m_nAttackGx, m_nAttackGy, 0);
                return false;
            }
            return true;
        }
        /*if(m_nAttackPhase==evacuating)
        {
        if(traceMode)     TraceD("evacuating: ");
        nDistance = Distance(m_nTargetGx,m_nTargetGy,GetLocationX(),GetLocationY());
        if(traceMode) {   TraceD(nDistance);TraceD("                \n");}
        if(!IsMoving() || nDistance>3)
        {
        m_nAttackPhase=nonAttack;
        }
        return false;
    }*/
        return false;
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
            if(traceMode)   TraceD("Rotating aircraft:");
            CallTurnToAngle(GetCannonAngleToTarget(0,m_uTarget));
            return true;
        }
        return false;
    }
    //-------------------------------------------------------
    function int CheckAmmo()
    {
        if(CannonRequiresSupply(0) && (m_bNeedReload || !GetAmmoCount()) && FindSupplyCenterPlace())
        {
            m_nState=0;
            if(state==AttackingPoint)
                m_nState = 1;
            if(state==Attacking)
                m_nState = 2;
            if(state==Moving)
                m_nState = 3;
            
            m_nSpecialGx = GetLocationX(); 
            m_nSpecialGy = GetLocationY();
            
            m_nStayGx = GetFoundSupplyCenterPlaceX();
            m_nStayGy = GetFoundSupplyCenterPlaceY();
            m_nStayLz = GetFoundSupplyCenterPlaceZ();
            CallMoveAndLandToPointForce(m_nStayGx, m_nStayGy, m_nStayLz);
            return true;
        }
        return false;
    }
    //-------------------------------------------------------
    function int EndState()
    {
        NextCommand(1);
    }
    //********************************************************
    //************* S T A T E S ******************************
    //********************************************************
    
    
    //------------------------------------------------------- 
    
    state Nothing
    {
        if(traceMode)TraceD("N                                                 \n");
        
        if(movementMode==1) return HoldPosition;
        
        if(CheckAmmo())return MovingForGetSupply;
        
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
            m_nAttackPhase=nonAttack;
            return AutoAttacking;
        }
        return Nothing;
    }
    //----------------------------------------------------
    state HoldPosition
    {
        if(traceMode)TraceD("HP                                                 \n");
        
        if(CheckAmmo())return MovingForGetSupply;
        
        if(m_uTarget)
        { 
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget))
            {
                StopCannonFire(-1);
                SetTarget(null);
                m_nAttackPhase=nonAttack;
            }
            else
            {
                if(TargetInRange())
                {
                    if(traceMode)TraceD("HP Fire!!!                                                \n");
                    CannonFireToTarget(-1, m_uTarget, -1);
                    return HoldPosition;
                }
                else
                    SetTarget(null);
                return HoldPosition,10;
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
        
        if(CheckAmmo())return MovingForGetSupply;
        
        // pozostawaj w okolicach punktu
        nDistance = Distance(m_nStayGx,m_nStayGy,GetLocationX(),GetLocationY());
        if( nDistance > 18)
        {
            if(traceMode)TraceD("nDistance: > 12 !!!!!                                                \n  ");
            SetTarget(null);
            m_nAttackPhase=nonAttack;
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
            return Moving;          
        }
        
        if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget))
        {
            StopCannonFire(-1);
            SetTarget(null);
            m_nAttackPhase=nonAttack;
        }
        
        if (m_uTarget)
        {
            m_nTargetGx = m_uTarget.GetLocationX();
            m_nTargetGy = m_uTarget.GetLocationY();
            if(AttackRun(0))
            {
                if(traceMode)TraceD("AA    Fire!!!!                                           \n");
                CannonFireToTarget(-1, m_uTarget, 2);
            }
            return AutoAttacking;
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
        if(CheckAmmo())return MovingForGetSupply;
        if(AttackRun(1))
            CannonFireGround(-1, m_nTargetGx, m_nTargetGy, 0, 2);
        return AttackingPoint;
    }
    //----------------------------------------------------
    state Attacking
    {
        if(traceMode)TraceD("A                                                \n");
        if(CheckAmmo())return MovingForGetSupply;
        if (m_uTarget.IsLive())
        {
            m_nTargetGx = m_uTarget.GetLocationX();
            m_nTargetGy = m_uTarget.GetLocationY();
            if(AttackRun(0))
                CannonFireToTarget(-1, m_uTarget, 2);
            return Attacking;
        }
        else //target not exist
        {
            SetTarget(null);
            m_nAttackPhase=nonAttack;
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
        if(CheckAmmo())return MovingForGetSupply;
        if(m_uTarget)
        {
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget))
            {
                StopCannonFire(-1);
                SetTarget(null);
                m_nAttackPhase=nonAttack;
            }
            else
            {
                m_nTargetGx = m_uTarget.GetLocationX();
                m_nTargetGy = m_uTarget.GetLocationY();
                if(AttackRun(0))
                    CannonFireToTarget(-1, m_uTarget, -1);
                return Patrol;
            }
        }
        else
        {
            FindBestTarget();
        }   
        
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
        if(CheckAmmo())return MovingForGetSupply;
        if(m_uTarget)
        {
            if(!m_uTarget.IsLive() || !IsEnemy(m_uTarget))
            {
                StopCannonFire(-1);
                SetTarget(null);
                m_nAttackPhase=nonAttack;
            }
            else
            {
                m_nTargetGx = m_uTarget.GetLocationX();
                m_nTargetGy = m_uTarget.GetLocationY();
                if(AttackRun(0))
                    CannonFireToTarget(-1, m_uTarget, -1);
                return Escort;
            }
        }
        else
        {
            FindBestTarget();
        }
        
        if(!m_uSpecialUnit.IsLive())
        {
            m_uSpecialUnit=null;
            if(IsMoving())
            {
                CallStopMoving;
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
    
    //------------------------------------------------------- 
    //for Flyables
    state MovingForGetSupply
    {
        if (IsMoving())
        {
            if ((GetLocationX() == m_nStayGx) && (GetLocationY() == m_nStayGy) && (GetLocationZ() == m_nStayLz))
                        {
                            CallStopMoving();
                            return MovingForGetSupply,5;
                        }

            return MovingForGetSupply;
        }
        else
        {
            if ((GetLocationX() == m_nStayGx) && (GetLocationY() == m_nStayGy) && (GetLocationZ() == m_nStayLz))
            {
                CallGetFlyingSupply();
                return GettingSupply;
            }
            else
            {
                CallMoveAndLandToPointForce(m_nStayGx, m_nStayGy, m_nStayLz);
                return MovingForGetSupply;
            }
        }
    }
    
    state GettingSupply
    {
        if (IsGettingSupply())
        {
            return GettingSupply;
        }
        else
        {
            m_bNeedReload=false;
            if(m_nSpecialGx==GetLocationX() && m_nSpecialGy==GetLocationY()) m_nSpecialGx=m_nSpecialGx+5;
            CallMoveToPoint(m_nSpecialGx,m_nSpecialGy,0);
            
            if(m_nState==1)
                return AttackingPoint,40;
            
            if(m_nState==2)
                return Attacking,40;
            
            return Moving;
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
        true;
    }
    //------------------------------------------------------- 
    event OnCannonNoAmmo(int nCannonNum)
    {
        m_bNeedReload=true;
        if(CheckAmmo())state MovingForGetSupply;
        true;
    }
    //------------------------------------------------------- 
    event OnCannonFoundTarget(int nCannonNum, unit uTarget)
    {
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
        SetTarget(null);
        m_uSpecialUnit = null;
    }
    //------------------------------------------------------- 
    event OnConvertedToNewPlayer()
    {
        StopCannonFire(-1);
        SetTarget(null);
        m_uSpecialUnit = null;
        state Nothing;
    }
    
    //********************************************************
    //*********** C O M M A N D S ****************************
    //********************************************************
    command Initialize()
    {
        traceMode = 0;
        movementMode = 0;
        attackMode = 1;
        SetCannonFireMode(-1, disableFire);
        m_nAttackGx=-1;
        m_bNeedReload=false;
    }
    //--------------------------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
        SetTarget(null);
        m_uSpecialUnit = null;
    }
    //--------------------------------------------------------------------------
    command SetLights(int nMode) button lights priority 204
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
    command SetMovementMode(int nMode) button movementMode priority 205
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
    command SetAttackMode(int nMode) button attackMode priority 205
    {
        if (nMode == -1)
        {
            attackMode = (attackMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            attackMode = nMode;
        }
        NextCommand(0);
    }
    
    //--------------------------------------------------------------------------
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        SetTarget(null);
        StopCannonFire(-1);
        if(state==GettingSupply)return;
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        if(IsMoving())
            CallStopMoving();
        state Nothing;
    }
    //--------------------------------------------------------------------------
    /*command HoldPosition() button "translateCommandHoldPosition" description "translateCommandHoldPositionDescription" hotkey priority 20
    {
    SetTarget(null);
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    m_nStayLz = GetLocationZ();
    movementMode = 1;
    if(IsMoving())
    CallStopMoving();
    state HoldPosition;
    }*/
    
    //--------------------------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        SetTarget(null);
        m_nStayGx = nGx;
        m_nStayGy = nGy;
        m_nStayLz = nLz;
        m_nState = 3;
        if(state==GettingSupply) return;
        CallMoveToPoint(nGx, nGy, nLz);
        state StartMoving;
    }
    //--------------------------------------------------------------------------
    command Attack(unit uTarget) button "translateCommandAttack" description "translateCommandAttackDescription" hotkey priority 22
    {
        SetTarget(uTarget);
        m_nAttackPhase=nonAttack;
        m_nState = 2;
        if(state==GettingSupply) return;
        state Attacking;
    }
    
    /*komenda nie wystawiana na zewnatrz*/
    command AttackOnPoint(int nX, int nY, int nZ) hidden button "translateCommandAttack" 
    {
        SetTarget(null);
        m_nTargetGx = nX;
        m_nTargetGy = nY;
        m_nTargetLz = nZ;
        m_nAttackPhase = nonAttack;
        m_nState = 1;
        if(state==GettingSupply)return;
        state AttackingPoint;
    }
    
    //--------------------------------------------------------------------------
    /*  command Patrol(int nGx, int nGy, int nLz) button "translateCommandPatrol" description "translateCommandPatrolDescription" hotkey priority 29
    {
    if(state==GettingSupply)return;
    m_nSpecialGx = nGx;
    m_nSpecialGy = nGy;
    m_nSpecialLz = nLz;
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    m_nStayLz = GetLocationZ();
    CallMoveToPoint(nGx, nGy, nLz);
    m_nSpecialCounter = 1;
    state Patrol;
    }
    
      //--------------------------------------------------------------------------
      command Escort(unit uUnit) button "translateCommandEscort" description "translateCommandEscortDescription" hotkey priority 31 
      {
      if(state==GettingSupply)return;
      m_uSpecialUnit=uUnit;
      m_nSpecialGx=GetLocationX()-m_uSpecialUnit.GetLocationX();
      m_nSpecialGy=GetLocationY()-m_uSpecialUnit.GetLocationY();
      if(m_nSpecialGx > 2) m_nSpecialGx=2;
      if(m_nSpecialGx < -2) m_nSpecialGx=-2;
      if(m_nSpecialGy > 2) m_nSpecialGy=2;
      if(m_nSpecialGy < -2) m_nSpecialGy=-2;
      state Escort;
      }
    */
    //--------------------------------------------------------------------------
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        CallMoveInsideObject(uEntrance);
        m_nTargetGx = GetEntranceX(uEntrance);
        m_nTargetGy = GetEntranceY(uEntrance);
        m_nTargetLz = GetEntranceZ(uEntrance);
        state StartMoving;
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
    
    //for flyables
    command Land() button "translateCommandLand" description "translateCommandLandDescription" hotkey priority 31 
    {
        if(state==GettingSupply)return;
        CallLand();
        state Nothing;
    }
    
    command FlyForSupply() button "translateCommandGetSupply" description "translateCommandGetSupplyDescription" hotkey priority 50 
    {
        if(state==GettingSupply)return;
        if (HaveCannonsMissingAmmo())
        {
            if (FindSupplyCenterPlace())
            {
                m_nSpecialGx = GetLocationX(); 
                m_nSpecialGy = GetLocationY();
                
                m_nStayGx = GetFoundSupplyCenterPlaceX();
                m_nStayGy = GetFoundSupplyCenterPlaceY();
                m_nStayLz = GetFoundSupplyCenterPlaceZ();
                CallMoveAndLandToPointForce(m_nStayGx, m_nStayGy, m_nStayLz);//jak bylo Force to stawaly w slupku
                state MovingForGetSupply;
            }
            else
            {
                NextCommand(0);
            }
        }
        else
        {
            NextCommand(0);
        }
    }
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    //--------------------------------------------------------------------------
    /*button "Attack"
    description "euhwfduihewuif"
    hotkey   // flaga ze ma reagowac na klawisz do tej komendy
    priority 7 */
}