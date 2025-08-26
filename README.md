# Terraform AWS SQS DLQ Alarms Module

A focused Terraform module for creating CloudWatch alarms for Amazon SQS queues with emphasis on Dead Letter Queue (DLQ) monitoring. This module provides essential monitoring capabilities to detect when messages reach the DLQ and monitor queue performance.

## Features

- **Dead Letter Queue Detection**: Primary alarm for detecting messages sent to DLQ
- **Queue Performance Monitoring**: Alarms for queue depth and message age
- **Processing Failure Detection**: Identifies low message processing rates
- **High Volume Detection**: Alerts on unusual message reception spikes
- **Simple Configuration**: Streamlined variables and outputs
- **SNS Integration**: Configurable notification actions for alarm states

## Available Alarms

### Core Monitoring (Enabled by Default)
1. **Queue Message Age**: Detects processing delays in the main queue
2. **Queue Depth**: Monitors message backlog in the main queue
3. **DLQ Messages Received**: Triggers when messages reach the DLQ ⚠️ **Critical**

### Optional Monitoring
4. **Processing Failure**: Identifies low message deletion rates
5. **High Message Rate**: Detects unusual message volume spikes

## Usage

### Basic Usage with DLQ Monitoring

```hcl
module "sqs_dlq_alarms" {
  source = "./modules/terraform-aws-sqs-dlq-alarms"

  queue_name     = "my-application-queue"
  dlq_queue_name = "my-application-queue-dlq"

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Advanced Configuration

```hcl
module "sqs_dlq_alarms" {
  source = "./modules/terraform-aws-sqs-dlq-alarms"

  queue_name     = "order-processing-queue"
  dlq_queue_name = "order-processing-queue-dlq"

  # Notification configuration
  alarm_actions = [
    aws_sns_topic.critical_alerts.arn,
    aws_sns_topic.slack_notifications.arn
  ]
  ok_actions = [aws_sns_topic.recovery_notifications.arn]

  # DLQ specific settings
  dlq_threshold           = 0  # Alert on any message in DLQ
  dlq_period              = 300
  dlq_evaluation_periods  = 1  # Immediate alert

  # Main queue settings
  message_age_threshold   = 600   # Alert if messages older than 10 minutes
  queue_depth_threshold   = 50    # Alert if more than 50 messages queued

  # Optional alarms
  enable_processing_failure_alarm   = true
  enable_high_message_rate_alarm    = true
  processing_failure_threshold      = 5    # Minimum 5 messages processed per period
  high_message_rate_threshold       = 500  # Alert on more than 500 messages/period

  tags = {
    Environment = "production"
    Service     = "order-processing"
    Team        = "platform"
  }
}
```

### Queue Without DLQ

```hcl
module "sqs_alarms_no_dlq" {
  source = "./modules/terraform-aws-sqs-dlq-alarms"

  queue_name     = "simple-queue"
  dlq_queue_name = null  # No DLQ

  # Only main queue alarms will be created
  enable_dlq_alarm = false

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = "development"
  }
}
```

### Custom Alarm Periods and Thresholds

```hcl
module "sqs_custom_alarms" {
  source = "./modules/terraform-aws-sqs-dlq-alarms"

  queue_name     = "high-volume-queue"
  dlq_queue_name = "high-volume-queue-dlq"

  # Custom evaluation periods for more/less sensitive alarms
  dlq_evaluation_periods              = 1    # Immediate alert
  message_age_evaluation_periods      = 3    # 3 consecutive periods
  queue_depth_evaluation_periods      = 5    # 5 consecutive periods for stability

  # Custom periods
  dlq_period               = 60   # Check every minute
  message_age_period       = 180  # Check every 3 minutes
  queue_depth_period       = 600  # Check every 10 minutes

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = "production"
    Volume      = "high"
  }
}
```

## Integration with SNS and Slack

```hcl
# SNS Topic for alerts
resource "aws_sns_topic" "sqs_alerts" {
  name = "sqs-dlq-alerts"
  
  kms_master_key_id = aws_kms_key.sns.arn
}

# Slack webhook subscription
resource "aws_sns_topic_subscription" "slack_alerts" {
  topic_arn     = aws_sns_topic.sqs_alerts.arn
  protocol      = "https"
  endpoint      = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
}

# Email subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.sqs_alerts.arn
  protocol  = "email"
  endpoint  = "devops@company.com"
}

# Use with the module
module "sqs_dlq_alarms" {
  source = "./modules/terraform-aws-sqs-dlq-alarms"

  queue_name     = "critical-queue"
  dlq_queue_name = "critical-queue-dlq"
  
  alarm_actions = [aws_sns_topic.sqs_alerts.arn]
  ok_actions    = [aws_sns_topic.sqs_alerts.arn]

  tags = {
    Environment = "production"
    Criticality = "high"
  }
}
```

## Alarm Behavior

### DLQ Messages Received (Critical Alarm)
- **Purpose**: Detect when any message reaches the DLQ
- **Default Threshold**: 0 (triggers on any message)
- **Evaluation**: 1 period (immediate alert)
- **Alarm Name**: `{queue_name}-dlq-messages-received`
- **Use Case**: Critical alert for message processing failures

### Queue Message Age
- **Purpose**: Detect processing delays in the main queue
- **Default Threshold**: 15 minutes
- **Alarm Name**: `{queue_name}-message-age`
- **Use Case**: Performance monitoring and SLA compliance

### Queue Depth
- **Purpose**: Monitor message backlog
- **Default Threshold**: 100 messages
- **Evaluation**: 3 consecutive periods
- **Alarm Name**: `{queue_name}-depth`
- **Use Case**: Capacity planning and auto-scaling triggers

### Processing Failure (Optional)
- **Purpose**: Detect low message processing rates
- **Default Threshold**: 1 message processed per period
- **Alarm Name**: `{queue_name}-processing-failure`
- **Use Case**: Identifies processing bottlenecks

### High Message Rate (Optional)
- **Purpose**: Detect unusual message volume spikes
- **Default Threshold**: 1000 messages per period
- **Alarm Name**: `{queue_name}-high-message-rate`
- **Use Case**: Traffic spike detection

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| queue_name | Name of the primary SQS queue to monitor | `string` | n/a | yes |
| dlq_queue_name | Name of the dead letter queue (DLQ). Set to null if no DLQ exists | `string` | `null` | no |
| alarm_actions | List of ARNs to notify when alarm transitions to ALARM state | `list(string)` | `[]` | no |
| ok_actions | List of ARNs to notify when alarm transitions to OK state | `list(string)` | `[]` | no |
| tags | A map of tags to assign to the CloudWatch alarms | `map(string)` | `{}` | no |
| enable_dlq_alarm | Enable alarm for messages sent to dead letter queue | `bool` | `true` | no |
| dlq_threshold | Threshold for DLQ messages received alarm | `number` | `0` | no |
| dlq_period | Period for DLQ messages received alarm in seconds | `number` | `300` | no |
| dlq_evaluation_periods | Number of evaluation periods for DLQ messages received alarm | `number` | `1` | no |
| enable_message_age_alarm | Enable alarm for age of oldest message in main queue | `bool` | `true` | no |
| message_age_threshold | Threshold for message age alarm in seconds | `number` | `900` | no |
| message_age_period | Period for message age alarm in seconds | `number` | `300` | no |
| message_age_evaluation_periods | Number of evaluation periods for message age alarm | `number` | `2` | no |
| enable_queue_depth_alarm | Enable alarm for main queue depth | `bool` | `true` | no |
| queue_depth_threshold | Threshold for main queue depth alarm | `number` | `100` | no |
| queue_depth_period | Period for queue depth alarm in seconds | `number` | `300` | no |
| queue_depth_evaluation_periods | Number of evaluation periods for queue depth alarm | `number` | `3` | no |
| enable_processing_failure_alarm | Enable alarm for low message processing rate | `bool` | `false` | no |
| processing_failure_threshold | Minimum threshold for message deletion rate | `number` | `1` | no |
| processing_failure_period | Period for processing failure alarm in seconds | `number` | `600` | no |
| processing_failure_evaluation_periods | Number of evaluation periods for processing failure alarm | `number` | `2` | no |
| enable_high_message_rate_alarm | Enable alarm for high message reception rate | `bool` | `false` | no |
| high_message_rate_threshold | Threshold for high message rate alarm | `number` | `1000` | no |
| high_message_rate_period | Period for high message rate alarm in seconds | `number` | `300` | no |
| high_message_rate_evaluation_periods | Number of evaluation periods for high message rate alarm | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| queue_message_age_alarm_arn | ARN of the main queue message age alarm |
| queue_message_age_alarm_name | Name of the main queue message age alarm |
| queue_depth_alarm_arn | ARN of the main queue depth alarm |
| queue_depth_alarm_name | Name of the main queue depth alarm |
| processing_failure_alarm_arn | ARN of the message processing failure alarm |
| processing_failure_alarm_name | Name of the message processing failure alarm |
| high_message_rate_alarm_arn | ARN of the high message rate alarm |
| high_message_rate_alarm_name | Name of the high message rate alarm |
| dlq_messages_received_alarm_arn | ARN of the DLQ messages received alarm |
| dlq_messages_received_alarm_name | Name of the DLQ messages received alarm |
| all_alarm_arns | List of all created alarm ARNs |
| all_alarm_names | List of all created alarm names |

## Alarm Naming Convention

All alarms follow the pattern: `{queue_name}-{alarm_type}`

Examples:
- `order-queue-message-age`
- `order-queue-depth`
- `order-queue-dlq-messages-received`
- `order-queue-processing-failure`
- `order-queue-high-message-rate`

## Best Practices

1. **Start with Core Alarms**: Enable DLQ, queue depth, and message age alarms for most use cases
2. **Tune Thresholds**: Adjust thresholds based on your application's normal behavior patterns
3. **Use Evaluation Periods**: Set appropriate evaluation periods to avoid false alarms
4. **SNS Integration**: Always configure alarm_actions for critical alerts
5. **Tagging**: Use consistent tags for cost tracking and resource management
6. **Monitor DLQ Immediately**: Set DLQ threshold to 0 for immediate alerts on message failures
7. **Test Alarms**: Verify alarm behavior in non-production environments first

## Contributing

When contributing to this module:

1. Follow [Terraform best practices](https://www.terraform.io/docs/language/index.html)
2. Update documentation for any new variables or outputs
3. Add validation rules for new variables
4. Test with various configurations
5. Update examples as needed


## License

<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge" alt="License"></a>

<details>
<summary>Preamble to the Apache License, Version 2.0</summary>
<br/>
<br/>

Complete license is available in the [`LICENSE`](LICENSE) file.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
</details>