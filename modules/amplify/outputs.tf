output "amplify_app_id" {
  description = "ID of the Amplify app"
  value       = aws_amplify_app.static_website.id
}

output "amplify_app_name" {
  description = "Name of the Amplify app"
  value       = aws_amplify_app.static_website.name
}

output "amplify_app_default_domain" {
  description = "Default domain for the Amplify app"
  value       = aws_amplify_app.static_website.default_domain
}

output "amplify_app_production_url" {
  description = "Production branch URL"
  value       = "${aws_amplify_branch.branch.branch_name}.${aws_amplify_app.static_website.default_domain}"
}
