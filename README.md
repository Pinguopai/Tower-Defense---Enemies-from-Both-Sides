# 《两面来敌》

《两面来敌》是一款面向 Windows PC 的历史幻想题材塔防游戏项目。当前仓库依据第一版需求建立基础工程骨架，用于后续制作 Godot 客户端原型、Spring Boot 后端服务和 Docker 化开发环境。

## 项目结构

```text
client/        Godot 客户端工程
backend/       Spring Boot 后端工程
deploy/        Docker Compose、Nginx 与数据库初始化
docs/          需求与设计文档
```

## 第一版目标

- 完成一张可通关的上帝视角类 3D 塔防地图。
- 实现 3 个普通兵种、1 名武将、3 类敌人与波次进攻。
- 实现军资、文官后勤、城池耐久、胜负判定与战斗结算。
- 提供账号、存档、关卡配置和结算接口。
- 支持后端、MySQL、Redis、Nginx 的容器化部署。

## 本地启动方向

- 客户端：使用 Godot 4.x 打开 `client/project.godot`。
- 后端：安装 Maven 后在 `backend` 目录执行 `mvn spring-boot:run`。
- 部署：安装 Docker 后在 `deploy` 目录执行 `docker compose up -d`。
