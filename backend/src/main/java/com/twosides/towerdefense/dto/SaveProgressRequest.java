package com.twosides.towerdefense.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SaveProgressRequest(
        @NotNull Long playerId,
        @NotBlank String stageId,
        @Min(0) int chapter,
        @Min(0) int resources
) {
}
