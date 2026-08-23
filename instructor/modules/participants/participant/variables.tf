variable "name" {
  type        = string
  description = "Participant name, e.g. grace.hopper. Becomes the LOGIN_NAME and the Cognito username."
}

variable "identifier" {
  type        = string
  description = "The name upper-cased and stripped of punctuation, for object names."
}

variable "email_domain" {
  type        = string
  description = "Domain for the course-scoped address."
}

variable "shared" {
  type = object({
    prefix         = string
    database       = string
    warehouse      = string
    student_role   = string
    network_policy = string
  })
  description = "The class-wide objects every participant hangs off."
}

