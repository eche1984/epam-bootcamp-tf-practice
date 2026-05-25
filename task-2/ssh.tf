resource "aws_key_pair" "cmtr-d3wf0oa8-keypair" {
  key_name   = "cmtr-d3wf0oa8-keypair"
  public_key = var.ssh_key

  tags = {
    Project = var.project_tag
    ID      = var.id_tag
  }
}