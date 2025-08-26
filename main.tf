#
# SQS Dead Letter Queue Alarms Terraform Module
#

locals {
  alarm_actions = length(var.alarm_actions) > 0 ? var.alarm_actions : (
    var.sns_topic_arn != null && var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  )
  ok_actions = length(var.ok_actions) > 0 ? var.ok_actions : (
    var.sns_topic_arn != null && var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
  )
}

# Main Queue Age of Oldest Message
resource "aws_cloudwatch_metric_alarm" "queue_message_age" {
  count = var.enable_message_age_alarm ? 1 : 0

  alarm_name          = "${var.queue_name}-message-age"
  alarm_description   = "Messages in queue are older than ${var.message_age_threshold} seconds"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.message_age_evaluation_periods
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = var.message_age_period
  statistic           = "Maximum"
  threshold           = var.message_age_threshold
  
  alarm_actions             = local.alarm_actions
  ok_actions                = local.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data        = var.treat_missing_data

  dimensions = {
    QueueName = var.queue_name
  }

  tags = var.tags
}

#
# Main Queue Depth
#
resource "aws_cloudwatch_metric_alarm" "queue_depth" {
  count = var.enable_queue_depth_alarm ? 1 : 0

  alarm_name          = "${var.queue_name}-depth"
  alarm_description   = "Queue has too many messages (depth > ${var.queue_depth_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.queue_depth_evaluation_periods
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = var.queue_depth_period
  statistic           = "Maximum"
  threshold           = var.queue_depth_threshold

  alarm_actions             = local.alarm_actions
  ok_actions                = local.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data        = var.treat_missing_data

  dimensions = {
    QueueName = var.queue_name
  }

  tags = var.tags
}

#
# Message Processing Failures
#
resource "aws_cloudwatch_metric_alarm" "message_processing_failure" {
  count = var.enable_processing_failure_alarm ? 1 : 0

  alarm_name          = "${var.queue_name}-processing-failure"
  alarm_description   = "Queue message processing rate is too low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.processing_failure_evaluation_periods
  metric_name         = "NumberOfMessagesDeleted"
  namespace           = "AWS/SQS"
  period              = var.processing_failure_period
  statistic           = "Sum"
  threshold           = var.processing_failure_threshold

  alarm_actions             = local.alarm_actions
  ok_actions                = local.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data        = var.treat_missing_data

  dimensions = {
    QueueName = var.queue_name
  }

  tags = var.tags
}

#
# High Message Receive Rate (potential flood)
#
resource "aws_cloudwatch_metric_alarm" "high_message_rate" {
  count = var.enable_high_message_rate_alarm ? 1 : 0

  alarm_name          = "${var.queue_name}-high-message-rate"
  alarm_description   = "Queue is receiving too many messages (rate > ${var.high_message_rate_threshold} per ${var.high_message_rate_period}s)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.high_message_rate_evaluation_periods
  metric_name         = "NumberOfMessagesReceived"
  namespace           = "AWS/SQS"
  period              = var.high_message_rate_period
  statistic           = "Sum"
  threshold           = var.high_message_rate_threshold

  alarm_actions       = local.alarm_actions
  ok_actions          = local.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data = var.treat_missing_data

  dimensions = {
    QueueName = var.queue_name
  }

  tags = var.tags
}

#
# CloudWatch Alarm: Messages Sent to Dead Letter Queue
#
resource "aws_cloudwatch_metric_alarm" "dlq_messages_received" {
  count = var.enable_dlq_alarm && var.dlq_queue_name != null ? 1 : 0

  alarm_name          = "${var.queue_name}-dlq-messages-received"
  alarm_description   = "Messages are being sent to DLQ"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.dlq_evaluation_periods
  metric_name         = "NumberOfMessagesReceived"
  namespace           = "AWS/SQS"
  period              = var.dlq_period
  statistic           = "Sum"
  threshold           = var.dlq_threshold

  alarm_actions             = local.alarm_actions
  ok_actions                = local.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data        = var.treat_missing_data

  dimensions = {
    QueueName = var.dlq_queue_name
  }

  tags = var.tags
}
