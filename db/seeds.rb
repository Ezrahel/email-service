# ── Roles ───────────────────────────────────────────────────────
puts "Seeding roles..."

owner_role = Role.find_or_create_by!(slug: "owner") do |r|
  r.name = "Owner"
  r.system = true
  r.permissions = {
    manage_organization: true, manage_billing: true, manage_members: true,
    manage_api_keys: true, send_emails: true, read_analytics: true,
    manage_templates: true, manage_webhooks: true, manage_domains: true
  }
end

admin_role = Role.find_or_create_by!(slug: "admin") do |r|
  r.name = "Admin"
  r.system = true
  r.permissions = {
    manage_members: false, manage_api_keys: true, send_emails: true,
    read_analytics: true, manage_templates: true, manage_webhooks: true,
    manage_domains: true
  }
end

developer_role = Role.find_or_create_by!(slug: "developer") do |r|
  r.name = "Developer"
  r.system = true
  r.permissions = {
    send_emails: true, read_analytics: true, manage_templates: true,
    manage_webhooks: true
  }
end

readonly_role = Role.find_or_create_by!(slug: "read_only") do |r|
  r.name = "Read Only"
  r.system = true
  r.permissions = {
    read_analytics: true
  }
end

# ── Demo Organization ──────────────────────────────────────────
puts "Seeding demo organization..."

demo_org = Organization.find_or_create_by!(slug: "demo") do |o|
  o.name = "Demo Organization"
  o.plan = "enterprise"
  o.status = "active"
  o.monthly_email_quota = 100_000
  o.billing_email = "billing@demo.com"
end

# ── Demo User ──────────────────────────────────────────────────
puts "Seeding demo user..."

demo_user = User.find_or_create_by!(email: "admin@demo.com") do |u|
  u.first_name = "Demo"
  u.last_name = "Admin"
  u.password = "password123"
  u.status = "active"
end

Membership.find_or_create_by!(organization: demo_org, user: demo_user) do |m|
  m.role = owner_role
  m.status = "active"
end

# ── Additional Demo Users ──────────────────────────────────────
%w[developer@demo.com readonly@demo.com].each do |email|
  user = User.find_or_create_by!(email: email) do |u|
    u.first_name = email.split("@").first.capitalize
    u.password = "password123"
    u.status = "active"
  end

  role = email.include?("developer") ? developer_role : readonly_role

  Membership.find_or_create_by!(organization: demo_org, user: user) do |m|
    m.role = role
    m.status = "active"
  end
end

# ── API Key ────────────────────────────────────────────────────
puts "Seeding API key..."

api_key_record = demo_org.api_keys.find_or_create_by!(name: "Development Key") do |k|
  k.key_prefix = "em_dev_"
  k.key_digest = Digest::SHA256.hexdigest("em_dev_test_key_placeholder")
  k.key_last_chars = "lace"
  k.status = "active"
  k.scopes = %w[email:send email:read template:manage webhook:read]
  k.user = demo_user
end

puts ""
puts "  ┌─────────────────────────────────────────────────────────┐"
puts "  │  Demo Organization:  demo                               │"
puts "  │  Admin Email:        admin@demo.com                     │"
puts "  │  Password:           password123                        │"
puts "  │  API Key:            em_dev_test_key_placeholder        │"
puts "  └─────────────────────────────────────────────────────────┘"
puts ""

# ── Sample Domain ──────────────────────────────────────────────
puts "Seeding demo domain..."

sample_domain = demo_org.domains.find_or_create_by!(domain: "example.com") do |d|
  d.status = "verified"
  d.is_verified = true
  d.verified_at = Time.current
  d.verification_token = SecureRandom.hex(16)
  d.dkim_selector = "mailo"
  d.dkim_public_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC"
  d.spf_record = "v=spf1 include:mail.example.com ~all"
  d.dkim_record = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC"
  d.dmarc_record = "v=DMARC1; p=none; rua=mailto:dmarc@example.com"
  d.mx_record = "10 mail.example.com"
end

# ── DNS Records ────────────────────────────────────────────────
sample_domain.dns_records.find_or_create_by!(record_type: "TXT", name: "example.com") do |r|
  r.value = "v=spf1 include:mail.example.com ~all"
  r.expected_value = "v=spf1 include:mail.example.com ~all"
  r.is_verified = true
  r.status = "verified"
end

sample_domain.dns_records.find_or_create_by!(record_type: "TXT", name: "mailo._domainkey.example.com") do |r|
  r.value = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC"
  r.expected_value = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC"
  r.is_verified = true
  r.status = "verified"
end

# ── Sample Templates ───────────────────────────────────────────
puts "Seeding templates..."

welcome_template = demo_org.templates.find_or_create_by!(slug: "welcome") do |t|
  t.name = "Welcome Email"
  t.subject = "Welcome to {{ app_name }}, {{ name }}!"
  t.html_body = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding: 40px;">
      <div style="max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Welcome to {{ app_name }}!</h1>
        <p style="color: #666; font-size: 16px; line-height: 1.5;">
          Hi {{ name }},<br><br>
          We're thrilled to have you on board. Get started by exploring our platform.<br><br>
          <a href="{{ action_url }}" style="display: inline-block; padding: 12px 24px; background-color: #007bff; color: white; text-decoration: none; border-radius: 4px;">
            Get Started
          </a>
        </p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px;">
          Sent from {{ app_name }} &mdash; {{ company_address }}
        </p>
      </div>
    </body>
    </html>
  HTML
  t.text_body = "Welcome to {{ app_name }}, {{ name }}!\n\nGet started: {{ action_url }}"
  t.variables = [
    { name: "app_name", type: "string", required: true },
    { name: "name", type: "string", required: true },
    { name: "action_url", type: "string", required: true },
    { name: "company_address", type: "string", required: false }
  ]
end

reset_template = demo_org.templates.find_or_create_by!(slug: "password-reset") do |t|
  t.name = "Password Reset"
  t.subject = "Reset your {{ app_name }} password"
  t.html_body = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding: 40px;">
      <div style="max-width: 600px; margin: 0 auto;">
        <h1 style="color: #333;">Reset your password</h1>
        <p style="color: #666; font-size: 16px; line-height: 1.5;">
          Hi {{ name }},<br><br>
          You requested a password reset for your {{ app_name }} account.<br><br>
          <a href="{{ reset_url }}" style="display: inline-block; padding: 12px 24px; background-color: #dc3545; color: white; text-decoration: none; border-radius: 4px;">
            Reset Password
          </a>
        </p>
        <p style="color: #999; font-size: 14px;">
          This link expires in {{ expires_in }} hours. If you didn't request this, please ignore this email.
        </p>
      </div>
    </body>
    </html>
  HTML
  t.text_body = "Hi {{ name }},\n\nReset your password: {{ reset_url }}\n\nThis link expires in {{ expires_in }} hours."
  t.variables = [
    { name: "app_name", type: "string", required: true },
    { name: "name", type: "string", required: true },
    { name: "reset_url", type: "string", required: true },
    { name: "expires_in", type: "string", required: false }
  ]
end

# ── Template Versions ─────────────────────────────────────────
welcome_template.versions.find_or_create_by!(version: 1) do |v|
  v.subject = welcome_template.subject
  v.html_body = welcome_template.html_body
  v.text_body = welcome_template.text_body
  v.variables = welcome_template.variables
end

reset_template.versions.find_or_create_by!(version: 1) do |v|
  v.subject = reset_template.subject
  v.html_body = reset_template.html_body
  v.text_body = reset_template.text_body
  v.variables = reset_template.variables
end

# ── Provider Config ────────────────────────────────────────────
puts "Seeding provider config..."

demo_org.provider_configs.find_or_create_by!(provider_type: "smtp", name: "SMTP Fallback") do |p|
  p.credentials = {
    host: ENV.fetch("SMTP_HOST", "localhost"),
    port: ENV.fetch("SMTP_PORT", "1025"),
    username: ENV.fetch("SMTP_USERNAME", ""),
    password: ENV.fetch("SMTP_PASSWORD", "")
  }
  p.settings = { ssl: false, auth: "plain" }
  p.weight = 100
  p.priority = 1
  p.is_primary = true
  p.is_active = true
  p.max_attempts = 3
  p.region = "us"
end

# ── Webhook Endpoint ───────────────────────────────────────────
puts "Seeding webhook..."

demo_org.webhooks.find_or_create_by!(name: "Demo Webhook", url: "https://webhook.site/demo") do |w|
  w.events = %w[email.sent email.delivered email.failed email.bounced]
  w.secret = SecureRandom.hex(32)
  w.signing_key = "whsec_#{SecureRandom.hex(16)}"
  w.is_active = false
  w.status = "active"
end

puts ""
puts "Seed complete! #{Organization.count} orgs, #{User.count} users, #{Template.count} templates."
puts ""
