# EKS Add-ons (dynamic from list)
resource "aws_eks_addon" "addons" {
  for_each = { for addon in var.addons : addon.name => addon if addon.enable }

  cluster_name                 = aws_eks_cluster.main.name
  addon_name                   = each.value.name
  addon_version                = each.value.version
  resolve_conflicts_on_create  = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update  = each.value.resolve_conflicts_on_update
  service_account_role_arn     = each.value.service_account_role_arn

  depends_on = [
    aws_eks_node_group.main,
  ]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${each.value.name}"
  })
}


