# The robot's user (no password, no console – only for GitHub Actions)
resource "aws_iam_user" "github_deployer" {
  name = "github-actions-deployer"
}

# What the robot is allowed to do (only 2 doors!)
data "aws_iam_policy_document" "github_deployer" {
  # Door 1: see, upload and remove website files
  statement {
    sid       = "ListWebsiteBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid       = "WriteWebsiteFiles"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }

  # Door 2: clear the CloudFront cache
  statement {
    sid       = "ClearCloudFrontCache"
    actions   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

# Attach the rules to the robot user
resource "aws_iam_user_policy" "github_deployer" {
  name   = "deploy-website-only"
  user   = aws_iam_user.github_deployer.name
  policy = data.aws_iam_policy_document.github_deployer.json
}

output "ci_user_name" {
  value = aws_iam_user.github_deployer.name
}