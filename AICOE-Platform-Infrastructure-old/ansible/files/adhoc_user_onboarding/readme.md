* Install jq before running the script using: ```sudo yum install jq -y```

* New Team Onboarding: 
    
    run the `profile_create_ns.sh` file with namespace, lead, and team members' username as arguments (eg : sh profile_create_ns.sh NAMESPACE LEAD_UN "MEM1 MEM2 MEM3")


* Add member in existing team:

    run the `profile_add_users.sh` file with namespace, team members' username as arguments (eg : sh profile_create_ns.sh NAMESPACE "MEM1 MEM2 MEM3")

Note: if username is without '@deloitte.com' eg. if email is `abc@deloitte.com`, then `abc` is username