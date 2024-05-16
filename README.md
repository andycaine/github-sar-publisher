# github-sar-publisher

A stack to enable publishing to the Serverless Application Repository from a GitHub action

## Description

To allow GitHub to publish to the AWS Serverless Application Repository, you need to add GitHub as an OIDC provider in AWS and also add a role that can be assumed by GitHub with the permissions necessary to publish an application into the Serverless Application Repository.

## Getting started

`github-sar-publisher` can be deployed through the (Serverless Application Repository)[https://eu-west-2.console.aws.amazon.com/lambda/home#/create/app?applicationId=arn:aws:serverlessrepo:eu-west-2:211125310871:applications/github-sar-publisher]. You will need to provide the name of the bucket the SAM CLI is using for artifact uploads and your GitHub user / organisation name.

You should then be able to (connect to AWS from GitHub using OIDC)[https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services].  Your GitHub workflow should look something like this:

```yaml
name: Publish SAM App

on:
  release:
    types: [published]

env:
  AWS_ACCOUNT: '<the-aws-account-id-to-publish-to>'
  AWS_REGION: '<your-aws-region>'
  ARTIFACT_BUCKET: '<your-artifact-bucket>'

permissions:
  id-token: write  # required for requesting the JWT
  contents: read   # required for actions/checkout

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - name: Git clone
        uses: actions/checkout@v4
      - name: Build app
        run: |
          sam build
      - name: AWS login
        uses: aws-actions/configure-aws-credentials@v3
        with:
          role-to-assume: arn:aws:iam::${{ env.AWS_ACCOUNT }}:role/github-sar-publisher
          role-session-name: github-sar-publishing
          aws-region: ${{ env.AWS_REGION }}
      - name: Package app
        run: |
          sam package --s3-bucket ${{ env.ARTIFACT_BUCKET }} --output-template-file packaged.yaml
      - name: Publish app
        run: |
          sam publish --template packaged.yaml
```
