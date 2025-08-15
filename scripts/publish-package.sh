#!/bin/bash

# moni-ai-y-tiptap 包发布脚本
# 用于发布 y-tiptap fork 包到本地 Verdaccio registry

set -e

# 配置
REGISTRY_URL="http://registry.fufenxi.com:4873/"
VERSION="3.0.0-beta.22.1"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查当前目录
if [[ ! -f "package.json" ]]; then
    log_error "请在 moni-ai-y-tiptap 根目录执行此脚本"
    exit 1
fi

# 获取包信息
PACKAGE_NAME=$(node -p "require('./package.json').name")
CURRENT_VERSION=$(node -p "require('./package.json').version")

log_info "开始发布 y-tiptap fork 包到本地 registry..."
log_info "包名: $PACKAGE_NAME"
log_info "当前版本: $CURRENT_VERSION"
log_info "目标版本: $VERSION"

# 更新版本号到目标版本
if [[ "$CURRENT_VERSION" != "$VERSION" ]]; then
    log_info "更新版本号从 $CURRENT_VERSION 到 $VERSION"
    npm version "$VERSION" --no-git-tag-version
fi

# 安装依赖
if [[ ! -d "node_modules" ]]; then
    log_info "安装依赖..."
    npm install
fi

# 构建项目
log_info "构建项目..."
if npm run dist; then
    log_success "构建成功"
else
    log_error "构建失败"
    exit 1
fi

# 检查构建产物
if [[ ! -d "dist" ]]; then
    log_error "构建产物不存在，构建可能失败"
    exit 1
fi

# 尝试 unpublish (如果包已存在)
log_info "检查并清理已存在的版本: $PACKAGE_NAME@$VERSION"
npm unpublish "$PACKAGE_NAME@$VERSION" --registry="$REGISTRY_URL" 2>/dev/null || true

# 发布包
log_info "发布包: $PACKAGE_NAME@$VERSION"
if npm publish --registry="$REGISTRY_URL"; then
    log_success "发布成功: $PACKAGE_NAME@$VERSION"
else
    log_error "发布失败: $PACKAGE_NAME@$VERSION"
    exit 1
fi

# 验证发布
log_info "验证发布结果..."
sleep 2
if npm view "$PACKAGE_NAME@$VERSION" --registry="$REGISTRY_URL" > /dev/null 2>&1; then
    log_success "验证成功: 包已成功发布到 registry"
else
    log_error "验证失败: 无法在 registry 中找到发布的包"
    exit 1
fi

echo ""
log_success "y-tiptap fork 包发布完成!"
echo ""
log_info "验证命令:"
echo "npm view $PACKAGE_NAME@$VERSION --registry=$REGISTRY_URL"
echo ""
log_info "在其他项目中安装:"
echo "npm install $PACKAGE_NAME@$VERSION --registry=$REGISTRY_URL"