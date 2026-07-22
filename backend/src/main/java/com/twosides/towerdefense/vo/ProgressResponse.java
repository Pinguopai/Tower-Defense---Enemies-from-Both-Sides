package com.twosides.towerdefense.vo;

public record ProgressResponse(
        Long playerId,
        String stageId,
        int chapter,
        int resources
) {
}
