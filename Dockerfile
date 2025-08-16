FROM python:3.11-slim

RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# 关键：接收从 docker build 命令传入的代理构建参数
ARG HTTP_PROXY
ARG HTTPS_PROXY

# 在构建环境中设置代理，这将影响后续所有网络命令
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}

WORKDIR /app
COPY .0.1.2/ /app/

# 安装 Python 依赖（现在将通过代理访问）
RUN pip install --no-cache-dir -r requirements.txt \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --extra-index-url https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host pypi.tuna.tsinghua.edu.cn \
    --trusted-host mirrors.aliyun.com

# 清理代理环境变量，避免其被“烤”进最终镜像
ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""

EXPOSE 8000
CMD ["python", "-m", "mirix.server.fastapi_server", "--host", "0.0.0.0", "--port", "8000"]
