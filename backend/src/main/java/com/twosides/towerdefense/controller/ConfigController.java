package com.twosides.towerdefense.controller;

import com.twosides.towerdefense.service.GameConfigService;
import com.twosides.towerdefense.vo.GameConfigResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/config")
public class ConfigController {

    private final GameConfigService gameConfigService;

    public ConfigController(GameConfigService gameConfigService) {
        this.gameConfigService = gameConfigService;
    }

    @GetMapping("/mvp")
    public GameConfigResponse getMvpConfig() {
        return gameConfigService.getMvpConfig();
    }
}
