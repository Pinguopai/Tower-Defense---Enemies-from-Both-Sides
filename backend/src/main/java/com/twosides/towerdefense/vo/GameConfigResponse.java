package com.twosides.towerdefense.vo;

import java.util.List;

public record GameConfigResponse(
        List<String> soldiers,
        List<String> heroes,
        List<String> logistics,
        List<String> enemies,
        String firstStageId
) {
}
