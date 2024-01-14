variable "project-name" {}
variable "lambda-name" {}
variable "replacements" {
  type    = map(any)
  default = {}
}

data "archive_file" "zip" {
  type        = "zip"
  output_path = "${path.module}/result/${var.lambda-name}/index.zip"

  source {
    content  = templatefile("${path.module}/result/${var.lambda-name}.js", var.replacements)
    filename = "index.js"
  }
}

data "aws_iam_policy_document" "lambda-edge" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "lambda-edge" {
  count              = 1
  name_prefix        = "${var.project-name}-${var.lambda-name}"
  assume_role_policy = data.aws_iam_policy_document.lambda-edge.json
}

data "aws_iam_policy_document" "lambda-logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_policy" "lambda-logs" {
  count       = 1
  name_prefix = "${var.project-name}-${var.lambda-name}"
  path        = "/"
  policy      = data.aws_iam_policy_document.lambda-logs.json
}

resource "aws_iam_role_policy_attachment" "lambda-logs" {
  count      = 1
  role       = aws_iam_role.lambda-edge[0].name
  policy_arn = aws_iam_policy.lambda-logs[0].arn
}

resource "aws_lambda_function" "lambda-function" {
  count   = 1
  publish = true

  function_name    = "${var.project-name}-${var.lambda-name}"
  role             = aws_iam_role.lambda-edge[0].arn
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"

  depends_on = [
    aws_iam_role_policy_attachment.lambda-logs,
  ]
}

output "qualified-arn" {
  value = aws_lambda_function.lambda-function[0].qualified_arn
}