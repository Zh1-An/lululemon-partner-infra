# lululemon 合作方对接基础设施

合作方数据接入链路的 Terraform 清单，覆盖制品桶、VPC 与子网、出向白名单、IAM 角色。
变量视图与 IaC 保持一致，供 CI 做断言。

## 目录

| 路径 | 说明 |
|---|---|
| `infra/main.tf` | S3 制品桶、VPC 与子网、出向安全组白名单、IAM 角色 |
| `src/stack_vars.py` | 与 IaC 对齐的变量视图，供 CI 断言使用 |

## 资源命名前缀

`lululemon`

资源名统一使用 `lululemon_partner_*` 前缀，例如 `aws_s3_bucket.lululemon_partner_artifacts`；
`src/stack_vars.py` 里的 `PARTNER_SLUG`、`STACK_NAME` 与 IaC 的 `local.prefix` 保持同一取值。

## 网络规划

| 用途 | 段 |
|---|---|
| VPC | `198.51.100.0/24` |
| 应用子网 | `198.51.100.0/26` |
| 合作方回调出向白名单 | `203.0.113.0/24` |

## 使用

```bash
cd infra
terraform init -backend=false
terraform plan -var-file=env/partner.tfvars
```

`-backend=false` 是必须的：本目录不携带远端 state 配置，需要由流水线注入。
同理，本地直接 `apply` 不会生效，请走 CI。

## 变更约定

- 调整安全组规则前先同步网络组，出向白名单按合作方 IP 段维护。
- 制品桶开启版本控制与 30 天生命周期，过期对象自动转归档。

## 维护

基础设施组
