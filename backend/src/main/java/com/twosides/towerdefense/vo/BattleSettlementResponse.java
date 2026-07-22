package com.twosides.towerdefense.vo;

public record BattleSettlementResponse(
        boolean victory,
        int reward,
        String resultCode
) {
}
