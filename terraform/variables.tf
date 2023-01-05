variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "suffix" {
  type    = string
  default = "flask-chatrrr"
}

variable "db_username" {
  type    = string
  default = "flask_db"
}

variable "db_name" {
  type    = string
  default = "webproddatabase"
}

variable "image_tag" {
  description = "Corresponds to a git tag."
  default     = "latest"
}
