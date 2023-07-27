resource "aws_ecr_repository" "sample_lambda_repo" {
  name                 = "sample_lambda_repo"
}

resource "aws_lambda_function" "sample_lambda_repo_function" {
  function_name = "sampleLambdaRepo"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.sample_lambda_repo.repository_url}:latest"
  role          = aws_iam_role.sample_lambda_iam.arn
  timeout       = 30

  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }

  depends_on = [
    aws_ecr_repository.sample_lambda_repo
  ]
}

resource "aws_iam_role" "sample_lambda_iam" {
  name = "sample_lambda_iam"

  assume_role_policy = data.aws_iam_policy_document.sample_lambda_document.json
}

data "aws_iam_policy_document" "sample_lambda_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}


resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sample_lambda_repo_function.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "sample_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample_lambda_repo_function.function_name
  principal     = "logs.amazonaws.com"

  source_arn = aws_cloudwatch_log_group.lambda_log_group.arn
}
