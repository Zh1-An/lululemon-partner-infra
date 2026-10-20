"""stack variables mirrored from the partner IaC.

"""

from __future__ import annotations

# Partner identifier used as the resource-name prefix across the stack.
PARTNER_SLUG = "lululemon"
STACK_NAME = "lululemon-partner-sandbox"
REGION = "ap-east-1"

# Network layout, mirrored from infra/main.tf.
VPC_CIDR = "198.51.100.0/24"
APP_SUBNET_CIDR = "198.51.100.0/26"
CALLBACK_EGRESS_CIDR = "203.0.113.0/24"

# RFC 2606 reserved domain for the callback endpoint.
CALLBACK_HOST = "partner-callback.example.com"

ARTIFACT_BUCKET = "lululemon-partner-artifacts"


class LululemonPartnerStack:
    """Read-only view over the Terraform variables, for CI assertions."""

    def __init__(self, partner: str = PARTNER_SLUG) -> None:
        self.partner = partner

    def resource_prefix(self, env: str = "sandbox") -> str:
        return f"{self.partner}-partner-{env}"

    def assertions(self) -> dict[str, str]:
        return {
            "partner": self.partner,
            "vpc_cidr": VPC_CIDR,
            "callback_host": CALLBACK_HOST,
            "bucket": ARTIFACT_BUCKET,
        }


if __name__ == "__main__":
    stack = LululemonPartnerStack()
    print(stack.resource_prefix())
    print(stack.assertions())
