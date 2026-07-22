package com.twosides.towerdefense.vo;

public record LoginResponse(
        Long playerId,
        String username,
        String token
) {
}
