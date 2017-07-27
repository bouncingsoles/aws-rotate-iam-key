aws-rotate-iam-key
=========
This module will rotate the aws iam api key for supplied {{iam_username}} variable set for Windows or Linux.  It uses the awscli commands to create a new key, and then updates the key on the server.  A requirement is the {{iam_username}} only has 1 active key, or the 2nd key is set to INACTIVE.  It creates a new key when there is only 1.  If there are 2 active keys (max allowed on aws account) the playbook will fail.  The playbook will delete an inactive key to make room on the account supplied in {{iam_username}}.  

- Windows credentials location: C:\Users\\{{aws_cli_user}}\.aws
- Linux credentials are in determined from the ENV of {{aws_cli_user}} home directory.

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
 - notify_service (OPTIONAL)
   - Only needed if you need to restart a service after key is rotated.

Example host_vars file:
```sh
iam_username: bouncingsoles  
aws_cli_user: user1
aws_region: us-east-1
aws_cloudfront: true
##Optional
notify_service: httpd
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
