#
# Outputs for SQS Dead Letter Queue Alarms Module
#

#
# Main queue alarm outputs
#
output "queue_message_age_alarm_arn" {
  description = "ARN of the main queue message age alarm"
  value       = var.create_message_age_alarm ? aws_cloudwatch_metric_alarm.queue_message_age[0].arn : null
}

output "queue_message_age_alarm_name" {
  description = "Name of the main queue message age alarm"
  value       = var.create_message_age_alarm ? aws_cloudwatch_metric_alarm.queue_message_age[0].alarm_name : null
}

output "queue_depth_alarm_arn" {
  description = "ARN of the main queue depth alarm"
  value       = var.create_queue_depth_alarm ? aws_cloudwatch_metric_alarm.queue_depth[0].arn : null
}

output "queue_depth_alarm_name" {
  description = "Name of the main queue depth alarm"
  value       = var.create_queue_depth_alarm ? aws_cloudwatch_metric_alarm.queue_depth[0].alarm_name : null
}

output "processing_failure_alarm_arn" {
  description = "ARN of the message processing failure alarm"
  value       = var.create_processing_failure_alarm ? aws_cloudwatch_metric_alarm.message_processing_failure[0].arn : null
}

output "processing_failure_alarm_name" {
  description = "Name of the message processing failure alarm"
  value       = var.create_processing_failure_alarm ? aws_cloudwatch_metric_alarm.message_processing_failure[0].alarm_name : null
}

output "high_message_rate_alarm_arn" {
  description = "ARN of the high message rate alarm"
  value       = var.create_high_message_rate_alarm ? aws_cloudwatch_metric_alarm.high_message_rate[0].arn : null
}

output "high_message_rate_alarm_name" {
  description = "Name of the high message rate alarm"
  value       = var.create_high_message_rate_alarm ? aws_cloudwatch_metric_alarm.high_message_rate[0].alarm_name : null
}

#
# DLQ-specific alarm outputs
#
output "dlq_messages_received_alarm_arn" {
  description = "ARN of the DLQ messages received alarm"
  value       = var.create_dlq_alarm && var.dlq_queue_name != null ? aws_cloudwatch_metric_alarm.dlq_messages_received[0].arn : null
}

output "dlq_messages_received_alarm_name" {
  description = "Name of the DLQ messages received alarm"
  value       = var.create_dlq_alarm && var.dlq_queue_name != null ? aws_cloudwatch_metric_alarm.dlq_messages_received[0].alarm_name : null
}



#
# Summary outputs
#
output "all_alarm_arns" {
  description = "List of all created alarm ARNs"
  value = compact([
    var.create_message_age_alarm ? aws_cloudwatch_metric_alarm.queue_message_age[0].arn : null,
    var.create_queue_depth_alarm ? aws_cloudwatch_metric_alarm.queue_depth[0].arn : null,
    var.create_processing_failure_alarm ? aws_cloudwatch_metric_alarm.message_processing_failure[0].arn : null,
    var.create_high_message_rate_alarm ? aws_cloudwatch_metric_alarm.high_message_rate[0].arn : null,
    var.create_dlq_alarm && var.dlq_queue_name != null ? aws_cloudwatch_metric_alarm.dlq_messages_received[0].arn : null,
  ])
}

output "all_alarm_names" {
  description = "List of all created alarm names"
  value = compact([
    var.create_message_age_alarm ? aws_cloudwatch_metric_alarm.queue_message_age[0].alarm_name : null,
    var.create_queue_depth_alarm ? aws_cloudwatch_metric_alarm.queue_depth[0].alarm_name : null,
    var.create_processing_failure_alarm ? aws_cloudwatch_metric_alarm.message_processing_failure[0].alarm_name : null,
    var.create_high_message_rate_alarm ? aws_cloudwatch_metric_alarm.high_message_rate[0].alarm_name : null,
    var.create_dlq_alarm && var.dlq_queue_name != null ? aws_cloudwatch_metric_alarm.dlq_messages_received[0].alarm_name : null,
  ])
}
