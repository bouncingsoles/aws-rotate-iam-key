aws-rotate-iam-key
=========

This module will update the IAM key for a user account that you specify for Windows or Linux hosts.

Requirements
------------

You ansible server must have the AWSCLI configured with the correct permissions.

Role Variables
--------------
 - iam_username = The username password key that you want to rotate.
 - aws_cli_user = The user on the machine that needs the IAM key rotated.  This would be the user that is using the key in question.
 - aws_region = AWS region in use, I.E. us-east-1
 - aws_cloudfront = true/false

Dependencies
------------
aws-cli

Example Playbook
----------------

```sh
- name: Rotate keys used in AWS for hosts that use api keys.
  hosts: xxxx
  roles:
     - aws-rotate-iam-key
```
License
-------

BSD

Author Information
------------------

Patrick Durante
