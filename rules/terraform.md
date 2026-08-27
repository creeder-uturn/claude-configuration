---
paths:
  - "**/*.tf"
  - "**/*.tofu"
---

## Terraform/OpenTofu — commands & permissions

- **Always use tf** - When running terraform or opentofu commands, always use the `tf` command, instead of `tofu` or `terraform`. If that command fails due to lack of `.opentofu-version` or `.terraform-version` file, let the user know and pause.

- **No risky commands** - Only run `tf init`, `tf validate`, and `tf fmt` without explicit prompting. Do not run any other `tf` commands unless explicitly prompted.

- Never `-auto-approve` in a real environment. It is only acceptable when explicitly told to use it in a limited sandbox/testing capacity.

- **Terraform output must never be truncated**: always capture the full output to a file (e.g. redirect to `/tmp/claude/<project>/plan.txt`); never pipe through `head`, `tail`, or any length-limiting filter — truncated plans hide resource deletions and replacement cascades. Use the Bash tool's output directly or redirect to a file and `Read` it — avoid `2>&1 | tee`.

- **OpenTofu is preferred over Terraform** - Generally, \*.tf code is OpenTofu, not Terraform. Terraform code will have a `.terraform-version` file with it.

- OpenTofu is a fork of Terraform, so most things that apply to Terraform also apply to OpenTofu.

- TF and AWS commands should always set an AWS_PROFILE (or --profile). If you are unsure of the profile to use for a given repository or project folder, ask the user and pause.

## Terraform/OpenTofu — code conventions

- **IAM policies**: Always use `data "aws_iam_policy_document"` over `jsonencode()` for IAM policy JSON in Terraform/OpenTofu.

- **State backend can have local values** - OpenTofu supports local (static) values in state backend - follow the repositories conventions when writing a backend configuration (or `config.tf` file)

## Terraform/OpenTofu — verification

- When proving work is complete, if `tf fmt` runs clean, running `tf validate` as an additional verification step is not required.
