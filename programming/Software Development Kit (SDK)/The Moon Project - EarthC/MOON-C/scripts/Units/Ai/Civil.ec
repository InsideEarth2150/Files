
civil "translateScriptNameUnarmedVechicle"
{
    
    int  m_nStayGx;
    int  m_nStayGy;
    int  m_nStayLz;
    int  m_nSpecialGx; //Patrol point , escort
    int  m_nSpecialGy;
    int  m_nSpecialLz;
    int  m_nSpecialCounter;
        int  m_nState;
    unit m_uSpecialUnit;
    
    
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
    function int EndState()
    {
        NextCommand(1);
    }
    
    //********************************************************
    //************* S T A T E S ******************************
    //********************************************************
    
    state Retreat;
    state Nothing;
    state StartMoving;
    state Moving;
    state Patrol;
    state Escort;
    
    //------------------------------------------------------- 
    state Retreat
    {
        unit uTarget;
        if(!m_nSpecialCounter)
        {
            uTarget = FindClosestEnemy();
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
        
        if(!uTarget)
        {
            if(IsMoving())
                CallStopMoving();
            if(traceMode)TraceD("R->N                                                 \n");
            return Nothing;
        }
        CallMoveToPoint(2*GetLocationX()-uTarget.GetLocationX(),2*GetLocationY() - uTarget.GetLocationY(),GetLocationZ());
        if(traceMode)TraceD("R u                                                \n");
        return Retreat;
    }
    //------------------------------------------------------- 
    state Nothing
    {
        if(traceMode)TraceD("N                                                 \n");
        return Nothing;
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
        int nTargetGx;
        int nTargetGy;
        if(traceMode)
            TraceD("Escort                                                 \n");
        
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
        
        nTargetGx = m_uSpecialUnit.GetLocationX()+m_nSpecialGx;
        nTargetGy = m_uSpecialUnit.GetLocationY()+m_nSpecialGy;
        if(Distance(nTargetGx,nTargetGy,GetLocationX(),GetLocationY()) > 0)
        {
            if(traceMode)
                TraceD("Escort: updating position                                                \n  ");
            CallMoveToPoint(nTargetGx, nTargetGy, m_uSpecialUnit.GetLocationZ());
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
           
            
            if(m_nState==3)
            {
                CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
                return Moving;
            }
            
            if(m_nState==4)
                return Patrol;
            
            if(m_nState==5)
                return Escort;
            
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
        if((GetHP()*2)<=GetMaxHP())
        {
            m_nSpecialCounter=0;
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
        true;
    }
    //------------------------------------------------------- 
    event OnCannonFoundTarget(int nCannonNum, unit uTarget)
    {
        false;//gdyby zwrocic true to dzialko nie strzeli
    }
    //------------------------------------------------------- 
    event OnCannonEndFire(int nCannonNum, int nEndStatus)
    {
        false;
    }
    //------------------------------------------------------- 
    event OnFreezeForSupplyOrRepair(int nFreezeTicks)
    {
              if(state!=Froozen) m_nState = 0;
        if((state==Moving) || (state==StartMoving))
            m_nState=3;
        if(state==Patrol)
            m_nState=4;
        if(state==Escort)
            m_nState=5;
        CallFreeze(nFreezeTicks);
        state Froozen;
    }
    //------------------------------------------------------- 
    event OnTransportedToNewWorld()
    {
    }
    
    //********************************************************
    //*********** C O M M A N D S ****************************
    //********************************************************
    command Initialize()
    {
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        traceMode = 0;
    }
    //--------------------------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
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
            lights = nMode;
        }
        SetLightsMode(lights);
    }
    
    
    //--------------------------------------------------------------------------
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        if(IsMoving())
        {
            CallStopMoving();
            
        }
        state Nothing;
    }
    
    //--------------------------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        m_nStayGx = nGx;
        m_nStayGy = nGy;
        m_nStayLz = nLz;
                
                if(state==Froozen)
                {
                    m_nState = 3;
                }
                else
                {
                    CallMoveToPoint(nGx, nGy, nLz);
                    state StartMoving;
                }
        
    }
    //--------------------------------------------------------------------------
    command UserNoParam0() button "translateCommandRetreat" description "translateCommandRetreatDescription" hotkey priority 25
    {
        m_nSpecialCounter=0;
        state Retreat;
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
        state StartMoving;
    }
    
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    //--------------------------------------------------------------------------
    /*    command UserOneParam9(int nMode) hidden button traceMode priority 255
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