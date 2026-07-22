package com.twosides.towerdefense.service.impl;

import com.twosides.towerdefense.dto.SaveProgressRequest;
import com.twosides.towerdefense.service.ProgressService;
import com.twosides.towerdefense.vo.ProgressResponse;
import org.springframework.stereotype.Service;

@Service
public class ProgressServiceImpl implements ProgressService {

    @Override
    public ProgressResponse getProgress(Long playerId) {
        return new ProgressResponse(playerId, "prologue", 0, 0);
    }

    @Override
    public ProgressResponse saveProgress(SaveProgressRequest request) {
        return new ProgressResponse(request.playerId(), request.stageId(), request.chapter(), request.resources());
    }
}
