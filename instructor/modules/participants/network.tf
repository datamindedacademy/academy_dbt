# PAT authentication requires a network policy, and participants connect from
# arbitrary codespace IPs. Containment is the per-participant role, not the IP.
resource "snowflake_network_policy" "participants" {
  name            = "${var.prefix}_PARTICIPANTS"
  allowed_ip_list = ["0.0.0.0/0"]
  comment         = "Permissive by necessity: PAT authentication requires a network policy and participants connect from arbitrary codespace IPs."
}
