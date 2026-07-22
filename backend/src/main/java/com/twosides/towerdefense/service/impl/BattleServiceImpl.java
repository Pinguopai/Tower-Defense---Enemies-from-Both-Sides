package com.twosides.towerdefense.service.impl;

import com.twosides.towerdefense.dto.BattleSettlementRequest;
import com.twosides.towerdefense.service.BattleService;
import com.twosides.towerdefense.vo.BattleSettlementResponse;
import org.springframework.stereotype.Service;

@Service
public class BattleServiceImpl implements BattleService {

    @Override
    public BattleSettlementResponse settle(BattleSettlementRequest request) {
        boolean victory = request.cityHealth() > 0 && request.clearedWaves() >= request.totalWaves();
        int reward = victory ? 300 + request.cityHealth() / 10 + request.remainingSupplies() / 2 : 50;
        return new BattleSettlementResponse(victory, reward, victory ? "stage_cleared" : "city_lost");
    }
}
