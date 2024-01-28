data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "scale_spot_fleet" {
  function_name    = "scale_spot_fleet"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "python3.8"
}

resource "aws_cloudwatch_event_rule" "scale_in" {
  name                = "scale_in"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "scale_out" {
  name                = "scale_out"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "scale_in" {
  rule      = aws_cloudwatch_event_rule.scale_in.name
  target_id = "scale_spot_fleet"
  arn       = aws_lambda_function.scale_spot_fleet.arn
  input     = <<EOF
{
  "time": "08:00:00"
}
EOF
}

resource "aws_cloudwatch_event_target" "scale_out" {
  rule      = aws_cloudwatch_event_rule.scale_out.name
  target_id = "scale_spot_fleet"
  arn       = aws_lambda_function.scale_spot_fleet.arn
  input     = <<EOF
{
  "time": "17:00:00"
}
EOF
}