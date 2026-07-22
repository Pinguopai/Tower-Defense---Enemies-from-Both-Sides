package com.twosides.towerdefense.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record BattleSettlementRequest(
        @NotNull Long playerId,
        @NotBlank String stageId,
        @Min(0) int cityHealth,
        @Min(0) int remainingSupplies,
        @Min(0) int clearedWaves,
        @Min(1) int totalWaves
) {
}
