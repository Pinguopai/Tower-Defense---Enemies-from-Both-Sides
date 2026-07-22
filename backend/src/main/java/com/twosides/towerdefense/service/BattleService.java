package com.twosides.towerdefense.service;

import com.twosides.towerdefense.dto.BattleSettlementRequest;
import com.twosides.towerdefense.vo.BattleSettlementResponse;

public interface BattleService {

    BattleSettlementResponse settle(BattleSettlementRequest request);
}
