resource "aws_iam_user" "github-actions-admin" {
  name = "github-actions-admin"
}

resource "aws_iam_access_key" "github-actions-admin" {
  user = aws_iam_user.github-actions-admin.name
}

resource "aws_iam_policy_attachment" "github-actions-admin-administrator-access" {
  name       = "${aws_iam_user.github-actions-admin.name}-AdministratorAccess"
  users      = [aws_iam_user.github-actions-admin.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  lifecycle {
    ignore_changes = [users]
  }
}
