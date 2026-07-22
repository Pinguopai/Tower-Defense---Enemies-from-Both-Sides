package com.twosides.towerdefense.controller;

import com.twosides.towerdefense.dto.BattleSettlementRequest;
import com.twosides.towerdefense.service.BattleService;
import com.twosides.towerdefense.vo.BattleSettlementResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/battles")
public class BattleController {

    private final BattleService battleService;

    public BattleController(BattleService battleService) {
        this.battleService = battleService;
    }

    @PostMapping("/settlement")
    public BattleSettlementResponse settle(@Valid @RequestBody BattleSettlementRequest request) {
        return battleService.settle(request);
    }
}
