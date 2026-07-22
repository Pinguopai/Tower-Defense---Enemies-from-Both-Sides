package com.twosides.towerdefense.service;

import com.twosides.towerdefense.dto.SaveProgressRequest;
import com.twosides.towerdefense.vo.ProgressResponse;

public interface ProgressService {

    ProgressResponse getProgress(Long playerId);

    ProgressResponse saveProgress(SaveProgressRequest request);
}
