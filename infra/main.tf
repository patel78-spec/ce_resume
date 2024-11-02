resource "aws_s3_bucket" "web_bucket" {
  bucket = "my-cloud-resume-bucket-01-11-2024"

  tags = {
    Name    = "Test Bucket"
    Project = "CICD Infra"
  }
}



# Loop through each file and upload it to S3
resource "aws_s3_object" "upload_website_files" {
  bucket = aws_s3_bucket.web_bucket.id

  for_each = fileset("../website/", "**/*.*")

  key    = each.value                # This will be the filename as the S3 key
  source = "../website/${each.value}" # Full path to the file in the 'website' directory

  # Set the correct content type based on the file extension
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}


# CloudFront Origin Access Identity for secure access to S3
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for accessing S3 bucket securely from CloudFront"
}

# Update S3 bucket policy to allow CloudFront to access the bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_bucket.arn}/*"
      }
    ]
  })
}

data "github_repository" "main" {
  full_name = "patel78-spec/ce_resume"
}

resource "github_actions_secret" "AWS_S3_BUCKET" {
  repository      = data.github_repository.main.id
  secret_name     = "AWS_S3_BUCKET"
  plaintext_value = aws_s3_bucket.web_bucket.arn
}


# CloudFront Distribution for S3 bucket
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.web_bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }


  aliases = ["resume.dhruvpatel.click"] # Set your custom domain as the alternate domain

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.web_bucket.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:781014416157:certificate/c2476464-6c79-43ae-b20a-55efc85a5fee"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name    = "Test CloudFront Distribution"
    Project = "CICD Infra"
  }
}

# Existing Route 53 Hosted Zone
data "aws_route53_zone" "selected_zone" {
  name = "dhruvpatel.click" # Replace with your hosted zone name
}

# Route 53 A Record Alias for CloudFront
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "resume.dhruvpatel.click"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_lambda_function" "resfunc" {
  filename         = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name    = "resfunc"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "func.handler"
  runtime          = "python3.8"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_policy" "iam_policy_for_resume_project" {

  name        = "aws_iam_policy_for_terraform_resume_project_policy"
  path        = "/"
  description = "AWS IAM Policy for managing the resume project role"
    policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:UpdateItem",
			      "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateTable"            
          ],
          "Resource" : "arn:aws:dynamodb:us-east-1:781014416157:table/cloud-resume-test"
        },
      ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_resume_project.arn
  
}
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/func.py"
  output_path = "${path.module}/lambda/func.zip"
}

resource "aws_lambda_function_url" "url1" {
  function_name      = aws_lambda_function.resfunc.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins     = ["https://resume.dhruvpatel.click"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}


