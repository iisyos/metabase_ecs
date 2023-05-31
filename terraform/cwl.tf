resource "aws_cloudwatch_log_group" "metabase" {
  name              = "/ecs/metabase"
  retention_in_days = 30
}
