package com.twosides.towerdefense.controller;

import com.twosides.towerdefense.dto.SaveProgressRequest;
import com.twosides.towerdefense.service.ProgressService;
import com.twosides.towerdefense.vo.ProgressResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/progress")
public class ProgressController {

    private final ProgressService progressService;

    public ProgressController(ProgressService progressService) {
        this.progressService = progressService;
    }

    @GetMapping("/{playerId}")
    public ProgressResponse getProgress(@PathVariable Long playerId) {
        return progressService.getProgress(playerId);
    }

    @PostMapping
    public ProgressResponse saveProgress(@Valid @RequestBody SaveProgressRequest request) {
        return progressService.saveProgress(request);
    }
}
