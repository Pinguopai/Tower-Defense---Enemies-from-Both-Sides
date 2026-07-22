package com.twosides.towerdefense.service.impl;

import com.twosides.towerdefense.dto.LoginRequest;
import com.twosides.towerdefense.service.AuthService;
import com.twosides.towerdefense.vo.LoginResponse;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    @Override
    public LoginResponse login(LoginRequest request) {
        return new LoginResponse(1L, request.username(), "mvp-session-token");
    }
}
