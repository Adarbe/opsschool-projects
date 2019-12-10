resource "aws_s3_bucket" "tfs3-state" {
  bucket = "abenjamin-tfstate-bk"
  acl = "private"
  force_destroy = true
  tags = {
    Name = "tfstate S3 BK"
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = "${aws_s3_bucket.tfs3-state.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::abenjamin-tfstate-bk/*"
    }
  ]
}
POLICY
}

terraform {
  backend "s3" {
	bucket = "abenjamin-tfstate-bk"
	acl = "private"
	key = "terraform.tfstate"
	region = "us-east-1"
  }
}


resource "aws_s3_bucket" "elb-bk" {
	bucket = "abenjamin-elb-bk"
  	policy = <<-EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
		"Effect": "Allow",
		"Principal": "*",
		"Action": "s3:PutObject",
		"Resource": "arn:aws:s3:::abenjamin-elb-bk/*"
		}
				]
}
		EOF
}


output "s3_bucket_arn"{
  value = "${aws_s3_bucket.elb-bk.id}"
}







