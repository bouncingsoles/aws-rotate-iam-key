aws-rotate-iam-key
=========
This module will rotate the API key on the {{iam_username}} variable set for the Windows or Linux host.  It uses the awscli commands to create a new key, it will then updates the key on the server.  A requirement is the iam_username only has 1 active key, or the 2nd key is set to INACTIVE.  It will create a new key, if only 1 exists, or delete the disabled key on the account supplied in iam_username.  Windows files updated are C:\Users\\{{aws_cli_user}}\.aws. Linux files updated by the role are in /home/{{aws_cli_user}}/.aws

It will not delete an active key.

Requirements
------------
The awscli needs to be configured on the Ansible server running the playbook.  Ensure that you have correct permissions to reset and generate new IAM api keys from the account that runs the Ansible playbook.

Role Variables
--------------
Please define the following variables in host_vars for your server.
 - iam_username
   - AWS account that is has an IAM API key generated.
 - aws_cli_user
   - The account on the OS that has aws CLI configured.
 - aws_region
   - AWS region in use, I.E. us-east-1
 - aws_cloudfront
   - Enter true/false if you need access to AWS Cloudfront cli commands.

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
-- Need to be configured on the ansible server running the playbook.
-- Correct permissions to reset and generate new IAM api keys.



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
