repairer "translateScriptNameRepairer"
{
    consts
    {
        findTargetWaterUnit     = 1;
        findTargetFlyingUnit    = 2;
        findTargetNormalUnit    = 4;
        findTargetBuildingUnit  = 8;
        findTargetAnyUnit       = 15;
        
        //typ rasy (jakich IFF'ow szukamy
        findEnemyUnit       = 1;
        findAllyUnit        = 2;
        findNeutralUnit     = 4;
        findOurUnit         = 8;
        
        //kryterium szukania
        findDisabledUnit    = 8;
        findDamagedUnit     = 16;
        //typ szukanego obiektu
        findDestinationCivilUnit    = 1;
        findDestinationArmedUnit    = 2;
        findDestinationRepairerUnit = 4;
        findDestinationSupplyUnit   = 8;
        findDestinationAnyUnit      = 15;
        
        operationRepair = 0;
        operationCapture = 1;
        operationRepaint = 2;
        operationUpgrade = 3;
    }
    
    int  m_nMoveToX;
    int  m_nMoveToY;
    int  m_nMoveToZ;
    unit m_uCurrTarget;
    int m_nCurrOperation;//0-repairing, 1-converting, 2-repainting, 3-upgrading
    int m_nRepaintSideColor;
    int  m_nStayX;
    int  m_nStayY;
    int  m_nStayZ;
    
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
    
    enum repairMode
    {
        "translateCommandStateDontRepair",
        "translateCommandStateAutoRepair",
multi:
        "translateCommandStateRepairMode"
    }
    enum captureMode
    {
        "translateCommandStateDontCapture",
        "translateCommandStateAutoCapture",
multi:
        "translateCommandStateCaptureMode"
    }
    enum upgradeWeaponsMode
    {
        "translateCommandStateUpgradeWeapons",
        "translateCommandStateDontUpgradeWeapons",
multi:
        "translateCommandStateUpgradeWeaponsMode"
    }
    enum upgradeChasisMode
    {
        "translateCommandStateUpgradeChasis",
        "translateCommandStateDontUpgradeChasis",
multi:
        "translateCommandStateUpgradeChasisMode"
    }
    enum upgradeShieldMode
    {
        "translateCommandStateUpgradeShield",
        "translateCommandStateDontUpgradeShield",
multi:
        "translateCommandStateUpgradeShieldMode"
    }
    
    //********************************************************
    //********* F U N C T I O N S ****************************
    //********************************************************
    function int SetCurrentTarget(unit uTarget)
    {
        m_uCurrTarget = uTarget;
        SetTargetObject(m_uCurrTarget);
        return true;
    }
    
    function int FindTargetToRepair()
    {
        int i;
        int nTargetsCount;
        unit newTarget;
        
        
        BuildTargetsArray(findTargetWaterUnit|findTargetNormalUnit|findTargetBuildingUnit, findAllyUnit|findOurUnit,findDestinationAnyUnit);
        SortFoundTargetsArray();
        nTargetsCount=GetTargetsCount();
        if(nTargetsCount!=0)
        {
            StartEnumTargetsArray();
            for(i=0;i<nTargetsCount;i=i+1)
            {
                                if(traceMode)   TraceD(".");
                newTarget = GetNextTarget();
                                
                if(!newTarget.IsFroozen() && 
                                    CanBeRepaired(newTarget) && 
                                    (DistanceTo(newTarget.GetLocationX(),newTarget.GetLocationY())<6))
                                {
                                    if(traceMode)   TraceD(":");
                          m_nMoveToX = GetOperateOnTargetLocationX(newTarget);
                      m_nMoveToY = GetOperateOnTargetLocationY(newTarget);
                        m_nMoveToZ = GetOperateOnTargetLocationZ(newTarget);

                                    if(IsGoodPointForOperateOnTarget(newTarget,m_nMoveToX,m_nMoveToY,m_nMoveToZ))
                                    {
                                            if(traceMode)   TraceD("!");
                                            EndEnumTargetsArray();
                                            SetCurrentTarget(newTarget);
                                            return true;
                                    }
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
    
    function int FindTargetToCapture()
    {
        int i;
        int nTargetsCount;
        unit newTarget;
        
        BuildTargetsArray(findTargetWaterUnit|findTargetNormalUnit|findTargetBuildingUnit, findEnemyUnit,findDestinationAnyUnit);
        SortFoundTargetsArray();
        nTargetsCount=GetTargetsCount();
        
        if(nTargetsCount!=0)
        {
            if(traceMode)   TraceD("T>0                           \n");
            StartEnumTargetsArray();
            for(i=0;i<nTargetsCount;i=i+1)
            {
                newTarget = GetNextTarget();
                if(CanBeConverted(newTarget) && (DistanceTo(newTarget.GetLocationX(),newTarget.GetLocationY())<7))
                                {
                          m_nMoveToX = GetOperateOnTargetLocationX(newTarget);
                      m_nMoveToY = GetOperateOnTargetLocationY(newTarget);
                        m_nMoveToZ = GetOperateOnTargetLocationZ(newTarget);

                                    if(IsGoodPointForOperateOnTarget(newTarget,GetOperateOnTargetLocationX(newTarget),GetOperateOnTargetLocationY(newTarget),GetOperateOnTargetLocationZ(newTarget)))
                                    {
                                            EndEnumTargetsArray();
                                            SetCurrentTarget(newTarget);
                                            return true;
                                    }
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
    
    
    state Initialize;
    state Nothing;
    state StartMoving;
    state Moving;
    state MovingToTarget;
    state Repairing;
    state Converting;
    state Repainting;
    state Upgrading;
        
    state Initialize
    {
        return Nothing;
    }
    

    state Nothing
    {
                if(traceMode)   TraceD("N");

                if(IsMoving())
                {
                    if(traceMode)   TraceD(" IsMoving                    \n");
                    return Nothing;
                }
                if(InPlatoon())
        {
                    m_nStayX = GetLocationX();
                    m_nStayY = GetLocationY();
                    m_nStayZ = GetLocationZ();
                }
                
                
                if(repairMode)
        {
            if(FindTargetToRepair())
            {
                                
                m_nCurrOperation = operationRepair;
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                                if(traceMode)   TraceD("-> MTT                           \n");
                return MovingToTarget;
            }
        }
        if(captureMode)
        {
            if(traceMode)   TraceD("captureMode                           \n");
            if(FindTargetToCapture())
            {
                if(traceMode)   TraceD("Target found                           \n");
                m_nCurrOperation = operationCapture;
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToTarget;
            }
        }
                if(InPlatoon())
        {
                    if(traceMode)   TraceD(" IP                          \n");
                    return Nothing;    
        }
                
                if(m_nStayX && (GetLocationX()!=m_nStayX || GetLocationY()!=m_nStayY ||GetLocationZ()!=m_nStayZ))
                {
                    if(traceMode)   TraceD("-> M                           \n");
                    SetCurrentTarget(null);
                    m_nMoveToX = m_nStayX;
                    m_nMoveToY = m_nStayY;
                    m_nMoveToZ = m_nStayZ;
                CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                    return StartMoving;
                }
                if(traceMode)   TraceD("                           \n");
        
    }
    
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
            NextCommand(1);
            return Nothing;
        }
    }
    
    state MovingToTarget
    {
        
        if (IsMoving())
        {
            //!!sprawdzanie czy cel jeszcze mozna naprawic/zdisablowac i czy sie ruszyl (wtedy trzeba zmienic kierunek jazdy)


            if (!m_uCurrTarget.IsFroozen() && 
                                ((m_nCurrOperation == operationRepair) && CanBeRepaired(m_uCurrTarget)) || 
                ((m_nCurrOperation == operationCapture) && CanBeConverted(m_uCurrTarget)) ||
                ((m_nCurrOperation == operationRepaint) && CanBeRepainted(m_uCurrTarget)) ||
                ((m_nCurrOperation == operationUpgrade) && CanBeUpgraded(m_uCurrTarget)))
            {
                                if(!IsGoodPointForOperateOnTarget(m_uCurrTarget,m_nMoveToX,m_nMoveToY,m_nMoveToZ))            
                                {//target has moved
                                        m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
                                        m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
                                        m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
                                        if(IsGoodPointForOperateOnTarget(m_uCurrTarget,m_nMoveToX,m_nMoveToY,m_nMoveToZ))            
                                        {
                                            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                                            return MovingToTarget;
                                        }
                                        else
                                        {//unable to find operation point for target
                                            m_nCurrOperation = operationRepair;
                                            CallStopMoving();
                                            SetCurrentTarget(null);
                                            NextCommand(1);
                                            return Nothing;
                                        }
                                }
            }
            else
            {
                m_nCurrOperation = operationRepair;
                CallStopMoving();
                SetCurrentTarget(null);
                                NextCommand(1);
                return Nothing;
            }
            return MovingToTarget;
        }
        else
        {
            //sprawdzic czy w punkcie w ktorym jestesmy mozemy zaczac naprawe
            if (IsInGoodPointForOperateOnTarget(m_uCurrTarget))
            {
                if (m_nCurrOperation == operationRepair)
                {
                    if (CanBeRepaired(m_uCurrTarget))
                    {
                        CallRepair(m_uCurrTarget);
                        return Repairing;
                    }
                    else
                    {
                        SetCurrentTarget(null);
                        NextCommand(1);
                        return Nothing;
                    }
                }
                else if (m_nCurrOperation == operationCapture)
                {
                    if (CanBeConverted(m_uCurrTarget))
                    {
                        CallConvert(m_uCurrTarget);
                        return Converting;
                    }
                    else
                    {
                        SetCurrentTarget(null);
                        NextCommand(1);
                        return Nothing;
                    }
                }
                else if (m_nCurrOperation == operationRepaint)
                {
                    if (CanBeRepainted(m_uCurrTarget))
                    {
                        CallRepaint(m_uCurrTarget, m_nRepaintSideColor);
                        return Repainting;
                    }
                    else
                    {
                        SetCurrentTarget(null);
                        NextCommand(1);
                        return Nothing;
                    }
                }
                else
                {
                    assert m_nCurrOperation == operationUpgrade;
                    if (CanBeUpgraded(m_uCurrTarget))
                    {
                        CallUpgrade(m_uCurrTarget);
                        return Upgrading;
                    }
                    else
                    {
                        SetCurrentTarget(null);
                        NextCommand(1);
                        return Nothing;
                    }
                }
            }
            else
            {
                m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
                m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
                m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
                                if(IsGoodPointForOperateOnTarget(m_uCurrTarget,m_nMoveToX,m_nMoveToY,m_nMoveToZ))            
                                {
                                            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                                            return MovingToTarget;
                                }
                                else
                                {//unable to find operation point for target
                                    m_nCurrOperation = operationRepair;
                                    CallStopMoving();
                                    SetCurrentTarget(null);
                                    NextCommand(1);
                                    return Nothing;
                                }
            }
            /*
            }
            else
            {
            SetCurrentTarget(null);
            NextCommand(1);
            return Nothing;
            }
            */
        }
    }
    
    state Repairing
    {
        if (IsRepairing())
        {
            return Repairing,5;
        }
        else
        {
            if (CanBeRepaired(m_uCurrTarget))
            {
                //z jakiegos powodu jeszcze go nie naprawilismy - odjechal ?
                m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
                m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
                m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToTarget;
            }
            else
            {
                SetCurrentTarget(null);
                NextCommand(1);
                return Nothing;
            }
        }
    }
    
    state Converting
    {
        if (IsConverting())
        {
            return Converting,5;
        }
        else
        {
            if (CanBeConverted(m_uCurrTarget))
            {
                //z jakiegos powodu jeszcze go nie skonvertowaliœmy - odjechal ?
                m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
                m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
                m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToTarget;
            }
            else
            {
                SetCurrentTarget(null);
                NextCommand(1);
                return Nothing;
            }
        }
    }
    
    state Repainting
    {
        if (IsRepainting())
        {
            return Repainting,5;
        }
        else
        {
            if (m_uCurrTarget.IsLive() && (m_uCurrTarget.GetSideColor() != m_nRepaintSideColor))
            {
                //z jakiegos powodu jeszcze go nie pomalowalismy - odjechal ?
                m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
                m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
                m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToTarget;
            }
            else
            {
                SetCurrentTarget(null);
                NextCommand(1);
                return Nothing;
            }
        }
    }
    
    state Upgrading
    {
        if (IsUpgrading())
        {
            return Upgrading,5;
        }
        else
        {
            if (m_uCurrTarget.IsLive() && CanBeUpgraded(m_uCurrTarget))
            {
                //z jakiegos powodu jeszcze go nie zubgradeowalismy - odjechal ?
                m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
                m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
                m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToTarget;
            }
            else
            {
                SetCurrentTarget(null);
                NextCommand(1);
                return Nothing;
            }
        }
    }
    
    //------------------------------------------------------- 
    state Froozen
    {
        if (IsFroozen())
        {
            return Froozen;
        }
        else
        {
            //!!wrocic do tego co robilismy
            return Nothing;
        }
    }
    //=================================================================================
    
    event OnFreezeForSupplyOrRepair(int nFreezeTicks)
    {
        CallFreeze(nFreezeTicks);
        state Froozen;
        true;
    }
    //------------------------------------------------------- 
    
    command Initialize()
    {
        int nColor;
        int nMaxColor;
        nMaxColor = GetMaxSideColor();
        m_nRepaintSideColor = GetSideColor();
        for (nColor = m_nRepaintSideColor + 1; nColor <= nMaxColor; nColor = nColor + 1)
        {
            if (IsPlayer(nColor))
            {
                m_nRepaintSideColor = nColor;
                break;
            }
        }
        if (nColor > nMaxColor)
        {
            for (nColor = 0; nColor < m_nRepaintSideColor; nColor = nColor + 1)
            {
                if (IsPlayer(nColor))
                {
                    m_nRepaintSideColor = nColor;
                    break;
                }
            }
        }
        SetRepaintSideColor(m_nRepaintSideColor);
        repairMode = 1;
        captureMode = 1;
        false;
    }
    
    command Uninitialize()
    {
        //wykasowac referencje
        SetCurrentTarget(null);
        false;
    }
    
    /*bez nazwy - wywolywany przez kursor*/
    command Repair(unit uTarget) hidden button "translateCommandRepair"
    {
        if (CanBeRepaired(uTarget))
        {
            m_nCurrOperation = operationRepair;
            SetCurrentTarget(uTarget);
            m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
            m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
            m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToTarget;
        }
        else
        {
            NextCommand(0);
        }
        true;
    }
    //-------------------------------------------------------    
    /*bez nazwy - wywolywany przez kursor*/
    command Convert(unit uTarget) hidden button "translateCommandCapture"
    {
        if (CanBeConverted(uTarget))
        {
            m_nCurrOperation = operationCapture;
            SetCurrentTarget(uTarget);
            m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
            m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
            m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToTarget;
        }
        else
        {
            NextCommand(0);
        }
        true;
    }
    //-------------------------------------------------------
    command Repaint(unit uTarget) button "translateCommandRepaint" description "translateCommandRepaintDescription" hotkey priority 100
    {
        if (CanBeRepainted(uTarget))
        {
            m_nCurrOperation = operationRepaint;
            SetCurrentTarget(uTarget);
            m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
            m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
            m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToTarget;
        }
        else
        {
            NextCommand(0);
        }
        true;
    }
    //-------------------------------------------------------
    command Upgrade(unit uTarget) button "translateCommandUpgrade" description "translateCommandUpgradeDescription" hotkey priority 99
    {
        if (CanBeUpgraded(uTarget))
        {
            m_nCurrOperation = operationUpgrade;
            SetCurrentTarget(uTarget);
            m_nMoveToX = GetOperateOnTargetLocationX(m_uCurrTarget);
            m_nMoveToY = GetOperateOnTargetLocationY(m_uCurrTarget);
            m_nMoveToZ = GetOperateOnTargetLocationZ(m_uCurrTarget);
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToTarget;
        }
        else
        {
            NextCommand(0);
        }
        true;
    }
    //-------------------------------------------------------
    command SetUpgradeWeapons(int nMode) hidden button upgradeWeaponsMode priority 98
    {
        if (nMode == -1)
        {
            upgradeWeaponsMode = (upgradeWeaponsMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            upgradeWeaponsMode = nMode;
        }
        SetUpgradeWeapons(upgradeWeaponsMode);
        NextCommand(0);
        true;
    }
    //-------------------------------------------------------
    command SetUpgradeChasis(int nMode) hidden button upgradeChasisMode priority 97
    {
        if (nMode == -1)
        {
            upgradeChasisMode = (upgradeChasisMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            upgradeChasisMode = nMode;
        }
        SetUpgradeChasis(upgradeChasisMode);
        NextCommand(0);
        true;
    }
    //-------------------------------------------------------
    command SetUpgradeShield(int nMode) hidden button upgradeShieldMode priority 96
    {
        if (nMode == -1)
        {
            upgradeShieldMode = (upgradeShieldMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            upgradeShieldMode = nMode;
        }
        SetUpgradeShield(upgradeShieldMode);
        NextCommand(0);
        true;
    }
    //-------------------------------------------------------
    command SetRepaintSideColor(int nNewSideColor) hidden button "translateCommandSetColor" 
    {
        m_nRepaintSideColor = nNewSideColor;
        SetRepaintSideColor(m_nRepaintSideColor);
        NextCommand(1);
        true;
    }
    //-------------------------------------------------------
    command SpecialSetRepaintSideColorDialog() button "translateCommandSetColor" description "translateCommandSetColorDescription" hotkey priority 101
    {
        //specjalna komenda obslugiwana przez dialog
    }
    //-------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        SetCurrentTarget(null);
        m_nMoveToX = nGx;
        m_nMoveToY = nGy;
        m_nMoveToZ = nLz;
                m_nStayX = nGx;
                m_nStayY = nGy;
                m_nStayZ = nLz;
    
        CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
        state StartMoving;
        true;
    }
    //-------------------------------------------------------
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        SetCurrentTarget(null);
        m_nMoveToX = GetEntranceX(uEntrance);
        m_nMoveToY = GetEntranceY(uEntrance);
        m_nMoveToZ = GetEntranceZ(uEntrance);
        CallMoveInsideObject(uEntrance);
        state StartMoving;
        true;
    }
    //-------------------------------------------------------
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        SetCurrentTarget(null);
        CallStopMoving();
        state Nothing;
        true;
    }
    
    //-------------------------------------------------------
    command SetRepairMode(int nMode) button repairMode description "translateCommandStateRepairModeDescription"priority 190
    {
        if (nMode == -1)
        {
            repairMode = (repairMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            repairMode = nMode;
        }
    }
    command SetConvertMode(int nMode) button captureMode description "translateCommandStateCaptureModeDescription" priority 190
    {
        if (nMode == -1)
        {
            captureMode = (captureMode + 1) % 2;
        }
        else
        {
            assert(nMode == 0);
            captureMode = nMode;
        }
    }
    
    //-------------------------------------------------------
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
    }
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    //--------------------------------------------------------------------------
/*    command UserOneParam9(int nMode) button traceMode priority 255
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
