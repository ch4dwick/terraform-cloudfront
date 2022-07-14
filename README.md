# Terraform AWS Cloudfront CDN Template

Terraform's ```aws_cloudfront_distribution``` configures a very minimal configuration that doesn't match what  you typically see when you create it from the web console. Hours of trial and error trying to get the bare minimum config needed to mimic the standard S3, Cloudfront & Route 53 mapping.

# How to use

## Initialize

> terraform init

After cherry-picking or tweaking the files to your needs:

## Validate

> terraform validate

## Apply Plan

> terraform apply


## Disclaimer:

This is a work in progress. I am by no means an expert on networking or on AWS. All of the configuration defined here are best-guess or defaults. I take no responsibility for any incurred costs resulting from the AWS resources created by these files. 