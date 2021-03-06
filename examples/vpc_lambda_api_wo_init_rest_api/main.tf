provider "aws" {
  region = "ap-southeast-1"
}

module "this" {
  source = "../../modules/api-gateway-resource"

  lambda_code_bucket = "${local.lambda_code_bucket}"
  lambda_code_path   = "${local.lambda_code_path}"
  lambda_name        = "${local.lambda_name}"
  lambda_runtime     = "${local.lambda_runtime}"
  lambda_handler     = "${local.lambda_handler}"
  lambda_memory_size = "${local.lambda_memory_size}"
  lambda_timeout     = "${local.lambda_timeout}"
  subnet_ids         = ["${local.subnet_ids}"]

  security_group_ids    = ["${local.security_group_ids}", "${aws_security_group.sg_lambda.id}"]
  environment           = "${local.environment}"
  product_domain        = "${local.product_domain}"
  environment_variables = "${local.environment_variables}"

  tags = "${local.tags}"
  is_vpc_lambda = "true"
  iam_policy_document = "${data.aws_iam_policy_document.this.json}"

  rest_api_id   = "${local.rest_api_id}"
  parent_id     = "${local.parent_id}"
  path_part     = "releasevccdata"
  http_methods   = [
    "GET",
    "POST"
  ]
  http_methods_apikey_required = [
    "false",
    "true"
  ]
  stage_name    = "v1"
}

### security group
resource "aws_security_group" "sg_lambda" {
  name        = "${local.lambda_name}"
  description = "${local.lambda_name} security group"
  vpc_id      = "${local.vpc_id}"

  tags = {
    Name          = "${local.lambda_name}"
    Environment   = "${local.environment}"
    productDomain = "${local.product_domain}"
    ManagedBy     = "terraform"
  }
}

resource "aws_security_group_rule" "lambda_egress_all_tcp" {
  type              = "egress" 
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg_lambda.id}"
}