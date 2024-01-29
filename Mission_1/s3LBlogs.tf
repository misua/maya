resource "aws_s3_bucket" "lb_logs" {
  bucket = "tf-my-lb-logs" 

  
  
  tags = {
    Name = "Load Balancer Logs"
  }
}

data "aws_iam_policy_document" "lb_logs" {
  statement {
    effect = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.lb_logs.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.lb_logs.arn]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.lb_logs.json
}


resource "aws_s3_bucket_public_access_block" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  block_public_acls   = false
  block_public_policy = false
}

