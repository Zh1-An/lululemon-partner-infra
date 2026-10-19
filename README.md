# lululemon 合作方对接基础设施（合成样本）

> ## ⚠️ SYNTHETIC TEST DATA - not a real leak. All data is fabricated.
>
> 本仓库是**授权内部检测链路自测**所用的金丝雀样本，内容 100% 合成。
> **第三方（含泄露情报厂商）请勿采信、勿扩散、勿作为任何泄露证据引用。**
> 所有 CIDR 均为 RFC 5737 文档段，所有主机名均在 `example.com` 之下，均为不可路由的保留值。

---

## 仓库用途

模拟「Terraform / IaC 清单被误推送到公开仓库」这一**基础设施类**泄露形态。
此类泄露不包含数据本体，但会暴露资源命名规范、网络规划、IAM 角色边界与部署区域，
在真实事件中常被作为横向移动的前置情报。

## 涉及的标识（合成）

```
lululemon
```

| 文件 | 命中位置 |
|---|---|
| `infra/main.tf` | 资源名 `aws_s3_bucket.lululemon_partner_artifacts`、`local.prefix` 默认值、`partner` 标签、注释与模块头 |
| `src/stack_vars.py` | 模块常量 `PARTNER_SLUG` / `STACK_NAME`、类名 `LululemonPartnerStack` |

## 文件清单

| 路径 | 说明 |
|---|---|
| `infra/main.tf` | S3 制品桶、VPC 与子网、出向安全组白名单、IAM 角色 |
| `src/stack_vars.py` | 与 IaC 对齐的变量视图，供 CI 断言使用 |

## 网络规划（文档段，不可路由）

| 用途 | 段 |
|---|---|
| VPC | `198.51.100.0/24` |
| 应用子网 | `198.51.100.0/26` |
| 合作方回调出向白名单 | `203.0.113.0/24` |

## 保留期限

本仓库为临时样本，**发布后 14 天内删除**。请勿 fork、勿镜像、勿归档。
本配置**不可 apply**：其中不含任何真实账号、状态后端或可用凭据。

---

*SYNTHETIC TEST DATA - not a real leak. All data is fabricated.*
