resource "aws_iam_user" "mail-sender" {
  name = "mail-sender"
  path = "/system/"
}

resource "aws_iam_access_key" "mail-sender" {
  user = aws_iam_user.mail-sender.name
}

resource "aws_iam_user_policy" "mail-sender_default" {
  name = "mail-sender-default-policy"
  user = aws_iam_user.mail-sender.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:SendRawMail"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
