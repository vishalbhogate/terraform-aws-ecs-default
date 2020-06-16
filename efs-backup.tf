resource aws_backup_vault "nfs" {
  count = var.expire_backup_efs > 0 ? 1 : 0
  name  = "vault-${var.name}"
}

resource aws_backup_plan "bkp_efs_plan" {
  count = var.expire_backup_efs > 0 ? 1 : 0
  name  = "Backup-${var.name}"

  rule {
    target_vault_name = aws_backup_vault.nfs[count.index].name
    rule_name         = "Daily-Backup-${var.name}"
    schedule          = "cron(0 22 * * ? *)"

    lifecycle {
      delete_after = var.expire_backup_efs
    }
  }
}

data aws_iam_policy_document "efs_backup_assume" {
  count = var.expire_backup_efs > 0 ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource aws_iam_role "efs_backup_role" {
  count              = var.expire_backup_efs > 0 ? 1 : 0
  name               = "Backup-efs-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.efs_backup_assume[count.index].json
}

resource aws_iam_role_policy_attachment "efs_backup_role" {
  count      = var.expire_backup_efs > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.efs_backup_role[count.index].name
}

resource aws_backup_selection "efs" {
  count        = var.expire_backup_efs > 0 ? 1 : 0
  iam_role_arn = aws_iam_role.efs_backup_role[count.index].arn
  name         = "Backup-efs-${var.name}"
  plan_id      = aws_backup_plan.bkp_efs_plan[count.index].id

  resources = [
    aws_efs_file_system.ecs.arn
  ]
}