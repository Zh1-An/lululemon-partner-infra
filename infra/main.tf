# =============================================================================
#  SYNTHETIC TEST DATA - not a real leak. All data is fabricated.
#  Canary fixture for authorised internal detection-pipeline validation.
#  Third-party leak-intelligence vendors MUST NOT treat this as evidence.
#
#  Stack   : lululemon partner integration (synthetic mirror)
#  Note    : all CIDRs are RFC 5737 documentation ranges, all hostnames are
#            under example.com. Applying this configuration is intentionally
#            not possible - it references no real account or region state.
# =============================================================================

terraform {
  required_version = ">= 1.6.0"
}

variable "partner_slug" {
  type        = string
  default     = "lululemon"
  description = "Partner identifier used as the resource name prefix."
}

variable "environment" {
  type    = string
  default = "sandbox"
}

locals {
  prefix = "${var.partner_slug}-partner-${var.environment}"
  tags = {
    partner     = "lululemon"
    environment = var.environment
    synthetic   = "true"
    owner       = "integration-platform"
  }
}

# -----------------------------------------------------------------------------
# Artifact bucket for the partner feed (synthetic name, does not exist)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "lululemon_partner_artifacts" {
  bucket        = "lululemon-partner-artifacts-synthetic"
  force_destroy = true

  tags = merge(local.tags, { Name = "${local.prefix}-artifacts" })
}

resource "aws_s3_bucket_lifecycle_configuration" "lululemon_partner_artifacts" {
  bucket = aws_s3_bucket.lululemon_partner_artifacts.id

  rule {
    id     = "expire-synthetic-fixtures"
    status = "Enabled"

    expiration {
      days = 14
    }
  }
}

# -----------------------------------------------------------------------------
# Network - RFC 5737 documentation ranges only (198.51.100.0/24, 203.0.113.0/24)
# -----------------------------------------------------------------------------
resource "aws_vpc" "lululemon_partner_vpc" {
  cidr_block           = "198.51.100.0/24"
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name = "${local.prefix}-vpc" })
}

resource "aws_subnet" "lululemon_partner_app" {
  vpc_id            = aws_vpc.lululemon_partner_vpc.id
  cidr_block        = "198.51.100.0/26"
  availability_zone = "ap-east-1a"

  tags = merge(local.tags, { Name = "${local.prefix}-app" })
}

# -----------------------------------------------------------------------------
# Egress allow-list for the partner callback host (reserved domain)
# -----------------------------------------------------------------------------
resource "aws_security_group" "lululemon_partner_egress" {
  name        = "${local.prefix}-egress"
  description = "Allow HTTPS to partner callback host (synthetic)"
  vpc_id      = aws_vpc.lululemon_partner_vpc.id

  egress {
    description = "partner callback - example.com reserved domain"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]
  }

  tags = merge(local.tags, { Name = "${local.prefix}-egress" })
}

# -----------------------------------------------------------------------------
# IAM role consumed by the partner sync job
# -----------------------------------------------------------------------------
resource "aws_iam_role" "lululemon_partner_sync" {
  name = "${local.prefix}-sync-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
      Condition = {
        StringEquals = { "aws:RequestedRegion" = "ap-east-1" }
      }
    }]
  })

  tags = merge(local.tags, { Name = "${local.prefix}-sync-role" })
}

output "partner_artifact_bucket" {
  value = aws_s3_bucket.lululemon_partner_artifacts.bucket
}

output "partner_vpc_cidr" {
  value = aws_vpc.lululemon_partner_vpc.cidr_block
}
