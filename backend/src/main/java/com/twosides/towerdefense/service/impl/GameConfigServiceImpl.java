package com.twosides.towerdefense.service.impl;

import com.twosides.towerdefense.service.GameConfigService;
import com.twosides.towerdefense.vo.GameConfigResponse;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class GameConfigServiceImpl implements GameConfigService {

    @Override
    public GameConfigResponse getMvpConfig() {
        return new GameConfigResponse(
                List.of("刀盾兵", "弓手", "长枪兵"),
                List.of("守城将领"),
                List.of("筹饷型", "转运型"),
                List.of("普通步兵", "快速斥候", "重甲军", "精锐头目"),
                "main_city_defense"
        );
    }
}
