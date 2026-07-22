package com.twosides.towerdefense.service;

import com.twosides.towerdefense.dto.LoginRequest;
import com.twosides.towerdefense.vo.LoginResponse;

public interface AuthService {

    LoginResponse login(LoginRequest request);
}
