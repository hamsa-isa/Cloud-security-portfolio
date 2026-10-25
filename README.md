# Cloud Security Portfolio

Hands-on cloud security projects — practical work across AWS and Azure covering identity and access management, security monitoring, automated posture assessment, and cloud infrastructure hardening.

## Projects

### 1. IAM Tag-Based Conditional Access Policy
`/iam-tag-based-conditional-policy/`

A custom JSON IAM policy restricting EC2 access based on environment tags (`Env:production` / `Env:development`), including an explicit deny on tag modification to prevent the policy's own condition from being bypassed. Tested and verified correct allow/deny behaviour across production and development resources.

### 2. CloudTrail, CloudWatch & SNS Security Monitoring Pipeline
`/cloudtrail-cloudwatch-sns-monitoring/`

An end-to-end alerting pipeline detecting access to a Secrets Manager secret, using CloudTrail, a CloudWatch metric filter and alarm, and SNS notifications. Includes a real troubleshooting case study: diagnosing and resolving an alarm misconfiguration (Average vs. Sum statistic) through systematic, layer-by-layer investigation.

### 3. AWS Security Posture Assessment (Prowler)
`/aws-security-posture-assessment-prowler/`

An automated cloud security posture assessment using Prowler Cloud, connected via a least-privilege IAM role. Covers risk-based prioritization beyond raw severity labels, framework mapping to CIS AWS Foundations Benchmark, ISO 27001, and NIST CSF, and a case study catching a flawed automated remediation suggestion before applying it.

### 4. Secure Multi-AZ AWS VPC (Terraform)
`/Terraform_AWS_Secure_VPC/`

A production-style AWS network built entirely as Infrastructure as Code: 18 resources across two availability zones, including public and private subnets, internet and NAT gateways, explicit route table associations, HTTPS-only ingress scoped to the VPC, and a default security group stripped of all rules (CIS AWS Foundations Benchmark). Includes a step-by-step build walkthrough with plan and console evidence, a security decisions table, and a troubleshooting log of real Terraform errors.
