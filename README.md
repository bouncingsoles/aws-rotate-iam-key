aws-rotate-iam-key
=========
This module will update the IAM key for a user account that you specify for Windows or Linux hosts.

Requirements
------------
The awscli needs to be configured on the ansible server running the playbook.  Ensure that you have correct permissions to reset and generate new IAM api keys from the account that runs the ansible playbook.

Role Variables
--------------
Please define the following variables in host_vars for your server.
 - iam_username
   -AWS account that is has an IAM API key generated.
 - aws_cli_user
   -The account on the OS that has aws CLI configured.
 - aws_region
   -AWS region in use, I.E. us-east-1
 - aws_cloudfront
   -Enter true/false if you need access to AWS Cloudfront cli commands.

Example host_vars file:
```sh
iam_username: bouncingsoles  
aws_cli_user: user1
aws_region: us-east-1
aws_cloudfront: true
```

Dependencies
------------
- aws-cli
--Need to be configured on the ansible server running the playbook.
--Correct permissions to reset and generate new IAM api keys.



Example Playbook
----------------

```sh
- name: Rotate keys used in AWS for hosts that use api keys.
  hosts: xxxx
  roles:
     - bouncingsoles.aws-rotate-iam-key
```
License
-------

BSD

Author Information
------------------

Patrick Durante
