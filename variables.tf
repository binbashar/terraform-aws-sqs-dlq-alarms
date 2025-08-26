#
# SQS Dead Letter Queue Alarms Module - Variables
#

variable "queue_name" {
  description = "Name of the primary SQS queue to monitor"
  type        = string
}

variable "dlq_queue_name" {
  description = "Name of the dead letter queue (DLQ) associated with the primary queue. Set to null if no DLQ exists."
  type        = string
  default     = null
}

#
# Optional single-topic fallback for actions
#
variable "sns_topic_arn" {
  description = "SNS topic ARN used for both alarm and OK actions when explicit actions are not provided"
  type        = string
  default     = null
}

#
# Message Age Alarm Variables
#
variable "enable_message_age_alarm" {
  description = "Enable alarm for age of oldest message in main queue"
  type        = bool
  default     = true
}

variable "message_age_threshold" {
  description = "Threshold for message age alarm in seconds"
  type        = number
  default     = 300 # 5 minutes
}

variable "message_age_period" {
  description = "Period for message age alarm in seconds"
  type        = number
  default     = 300
}

variable "message_age_evaluation_periods" {
  description = "Number of evaluation periods for message age alarm"
  type        = number
  default     = 2
}

#
# Queue Depth Alarm Variables
#
variable "enable_queue_depth_alarm" {
  description = "Enable alarm for main queue depth"
  type        = bool
  default     = true
}

variable "queue_depth_threshold" {
  description = "Threshold for main queue depth alarm (number of messages)"
  type        = number
  default     = 100
}

variable "queue_depth_period" {
  description = "Period for queue depth alarm in seconds"
  type        = number
  default     = 300
}

variable "queue_depth_evaluation_periods" {
  description = "Number of evaluation periods for queue depth alarm"
  type        = number
  default     = 3
}

#
# Processing Failure Alarm Variables
#
variable "enable_processing_failure_alarm" {
  description = "Enable alarm for low message processing rate"
  type        = bool
  default     = false
}

variable "processing_failure_threshold" {
  description = "Minimum threshold for message deletion rate (messages deleted per period)"
  type        = number
  default     = 1
}

variable "processing_failure_period" {
  description = "Period for processing failure alarm in seconds"
  type        = number
  default     = 600
}

variable "processing_failure_evaluation_periods" {
  description = "Number of evaluation periods for processing failure alarm"
  type        = number
  default     = 2
}

#
# High Message Rate Alarm Variables
#
variable "enable_high_message_rate_alarm" {
  description = "Enable alarm for high message reception rate"
  type        = bool
  default     = false
}

variable "high_message_rate_threshold" {
  description = "Threshold for high message rate alarm (messages per period)"
  type        = number
  default     = 1000
}

variable "high_message_rate_period" {
  description = "Period for high message rate alarm in seconds"
  type        = number
  default     = 300
}

variable "high_message_rate_evaluation_periods" {
  description = "Number of evaluation periods for high message rate alarm"
  type        = number
  default     = 1
}

#
# DLQ Message Reception Alarm Variables
#
variable "enable_dlq_alarm" {
  description = "Enable alarm for messages sent to dead letter queue"
  type        = bool
  default     = true
}

variable "dlq_threshold" {
  description = "Threshold for DLQ messages received alarm (number of messages)"
  type        = number
  default     = 0
}

variable "dlq_period" {
  description = "Period for DLQ messages received alarm in seconds"
  type        = number
  default     = 300
}

variable "dlq_evaluation_periods" {
  description = "Number of evaluation periods for DLQ messages received alarm"
  type        = number
  default     = 1
}

#
# Common Alarm Variables
#
variable "alarm_actions" {
  description = "List of ARNs to notify when alarm transitions to ALARM state (e.g., SNS topic ARNs)"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm transitions to OK state"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs to notify when alarm transitions to INSUFFICIENT_DATA state"
  type        = list(string)
  default     = []
}

variable "treat_missing_data" {
  description = "Specifies how this alarm is to handle missing data points"
  type        = string
  default     = "notBreaching"
}

variable "tags" {
  description = "A map of tags to assign to the CloudWatch alarms"
  type        = map(string)
  default     = {}
}
