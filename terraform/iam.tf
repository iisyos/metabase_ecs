resource "aws_iam_role" "metabase" {
  name               = "metabase_ecs_task_execution_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "metabase" {
  name        = "metabase_ecs_task_execution_policy"
  description = "Allows ECS tasks to write logs to CloudWatch"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "${aws_cloudwatch_log_group.metabase.arn}:log-stream:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "metabase" {
  role       = aws_iam_role.metabase.name
  policy_arn = aws_iam_policy.metabase.arn
}