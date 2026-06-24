
# 安装docker-compose
https://github.com/docker/compose/releases


# 阿里云镜像中心
https://cr.console.aliyun.com/repository/cn-hangzhou/yaobo-box/aspnet/details

# 帐号密码
yaobo263384374   a263384374

# 登录阿里云Docker Registry
docker login --username=yaobo263384374 crpi-p35inr9lrgirg3t0.cn-hangzhou.personal.cr.aliyuncs.com
 
# 从Registry中拉取镜像
docker pull crpi-p35inr9lrgirg3t0.cn-hangzhou.personal.cr.aliyuncs.com/yaobo-box/aspnet:[镜像版本号]

# 推送到Registry
docker login --username=yaobo263384374 crpi-p35inr9lrgirg3t0.cn-hangzhou.personal.cr.aliyuncs.com
docker tag [ImageId] crpi-p35inr9lrgirg3t0.cn-hangzhou.personal.cr.aliyuncs.com/yaobo-box/aspnet:[镜像版本号]
docker push crpi-p35inr9lrgirg3t0.cn-hangzhou.personal.cr.aliyuncs.com/yaobo-box/aspnet:[镜像版本号]



# 接取镜像
docker pull crpi-p35inr9lrgirg3t0.cn-hangzhou.personal.cr.aliyuncs.com/yaobo-box/aspnet:1.0



# DaoCloud 中转
docker pull docker.m.daocloud.io/flashcatcloud/nightingale:8.5.1

# 或用 dockerproxy 中转
docker pull dockerproxy.com/flashcatcloud/nightingale:8.5.1