#!/usr/bin/env zsh
# ============================================================================
# AWS CLI SHORTCUTS  (zsh)
# Source this in your shell profile:
#   echo 'source ~/aws-cli-shortcuts.sh' >> ~/.zshrc
#
# Run `awshelp` to list every shortcut in a boxed cheatsheet.
# Run `awshelp ec2` (or s3, iam, lambda ...) to show just one section.
#
# Conventions:
#   - Every shortcut ends with "# description" so awshelp can pick it up.
#   - Section headers look like:  # ── NAME ───────
#   - EC2 shortcuts default to $EC2_ID when no instance id is given.
#     (ec2term always requires an explicit id, on purpose.)
# ============================================================================

# ── SAFETY HELPER ─────────────────────────────────────────────────────────
# Used by destructive commands. Usage: _confirm "message" || return 1
# zsh-native prompt (bash's `read -p` means something different in zsh)
_confirm() {
    read -r "reply?⚠️  $1 [y/N] "
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ── HELP ──────────────────────────────────────────────────────────────────
# Capture this file's path at source time (inside a function, $0 is the function name)
_AWS_SHORTCUTS_FILE="${(%):-%x}"

awshelp() { # Boxed cheatsheet. Filter by section: awshelp ec2
    awk -v q="$1" -v prof="${AWS_PROFILE:-default}" '
    function rep(s, n,   r) { r = ""; while (n-- > 0) r = r s; return r }

    # Section header: "# ── EC2 ────" -> box title
    /^# ── / {
        t = $0; sub(/^# ── /, "", t); sub(/ ──.*/, "", t)
        sec = ++ns; title[sec] = t; next
    }

    # Entry: alias or function with an inline "# description"
    /^[[:space:]]*(alias[[:space:]]+[A-Za-z0-9_-]+=|[A-Za-z0-9_]+\(\))/ && /[[:space:]]#[[:space:]]/ {
        line = $0; sub(/^[[:space:]]+/, "", line)
        if (line ~ /^alias/) { sub(/^alias[[:space:]]+/, "", line); name = line; sub(/=.*/, "", name) }
        else                 { name = line; sub(/\(.*/, "", name) }
        if (name ~ /^_/ || sec == 0) next
        d = $0; sub(/.*[[:space:]]#[[:space:]]/, "", d)
        if (length(d) > 62) d = substr(d, 1, 59) "..."
        n = ++cnt[sec]; nm[sec, n] = name; ds[sec, n] = d
        if (length(name) > nw) nw = length(name)
        if (length(d) > dw)    dw = length(d)
    }

    END {
        nw += 2
        W = 2 + nw + dw + 2
        head = "AWS CLI CHEATSHEET"
        lp = int((W - length(head)) / 2)
        print ""
        print "╔" rep("═", W) "╗"
        print "║" rep(" ", lp) head rep(" ", W - lp - length(head)) "║"
        print "╚" rep("═", W) "╝"
        print "  profile: " prof
        for (s = 1; s <= ns; s++) {
            if (!cnt[s]) continue
            if (q != "" && tolower(title[s]) !~ tolower(q)) continue
            shown++
            print ""
            print "┌─ " title[s] " " rep("─", W - length(title[s]) - 3) "┐"
            for (i = 1; i <= cnt[s]; i++) {
                row = sprintf("%-" nw "s%s", nm[s, i], ds[s, i])
                print "│  " row rep(" ", W - 2 - length(row)) "│"
            }
            print "└" rep("─", W) "┘"
        }
        if (q != "" && !shown) print "\n  No section matching \"" q "\". Run awshelp with no argument to see all."
        print ""
    }' "$_AWS_SHORTCUTS_FILE"
}

# ── PROFILES ──────────────────────────────────────────────────────────────
alias awswho='aws sts get-caller-identity'                      # Whoami
alias awsregion='aws configure get region --profile "${AWS_PROFILE:-default}"' # Query region (active profile)
awscfg()   { aws configure --profile "$1"; }                    # Create/edit a profile
awsp()     { export AWS_PROFILE="$1"; echo "AWS_PROFILE=$1"; }  # Switch profile (session)
awsregset(){ aws configure set region "$1" --profile "${2:-default}"; } # Change region

# ── EC2 ───────────────────────────────────────────────────────────────────
ec2ls()    { aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key=='Name']|[0].Value]" --output table; } # List instances (id/state/type/name)
ec2get()   { aws ec2 describe-instances --instance-ids "${1:-$EC2_ID}"; }    # Describe instance (default: $EC2_ID)
ec2start() { aws ec2 start-instances --instance-ids "${1:-$EC2_ID}"; }       # Start instance (default: $EC2_ID)
ec2stop()  { aws ec2 stop-instances --instance-ids "${1:-$EC2_ID}"; }        # Stop instance (default: $EC2_ID)
ec2reboot(){ aws ec2 reboot-instances --instance-ids "${1:-$EC2_ID}"; }      # Reboot instance (default: $EC2_ID)
ec2term()  { [[ -z "$1" ]] && { echo "Usage: ec2term <instance-id>"; return 1; }; _confirm "Terminate instance $1?" && aws ec2 terminate-instances --instance-ids "$1"; } # Terminate instance (id required)
ec2ip()    { aws ec2 describe-instances --instance-ids "${1:-$EC2_ID}" --query "Reservations[0].Instances[0].PublicIpAddress" --output text; } # Public IP (default: $EC2_ID)
ec2sgs()   { aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName]" --output table; } # List security groups
ec2ssh()   { aws ssm start-session --target "${1:-$EC2_ID}"; }               # SSM shell, no open SSH port (default: $EC2_ID)
ec2amis()  { aws ec2 describe-images --owners self --query "Images[*].[ImageId,Name,CreationDate]" --output table; } # List your AMIs

# ── S3 ────────────────────────────────────────────────────────────────────
alias s3l='aws s3 ls'                                            # List all buckets
s3mb()     { aws s3 mb "s3://$1"; }                               # Make bucket
s3rb()     { aws s3 rb "s3://$1"; }                               # Remove empty bucket
s3rbf()    { _confirm "Force-delete ALL contents of s3://$1?" && aws s3 rb --force "s3://$1"; } # Remove non-empty bucket (confirm)
s3cp()     { aws s3 cp "$1" "s3://$2"; }                          # Upload file
s3lsr()    { aws s3 ls --recursive "s3://$1"; }                   # List files (recursive)
s3size()   { aws s3 ls --recursive --human-readable --summarize "s3://$1"; } # Bucket size
s3sync()   { aws s3 sync "$1" "$2"; }                             # Sync dir <-> bucket
s3presign(){ aws s3 presign "s3://$1/$2" --expires-in "${3:-3600}"; } # Pre-signed URL

# ── IAM ───────────────────────────────────────────────────────────────────
iamrole()    { aws iam get-role --role-name "$1"; }               # Get role info
iamrolepol() { aws iam get-role-policy --role-name "$1" --policy-name "$2"; } # Get role policy
iamroles()   { aws iam list-roles --query "Roles[*].RoleName"; }  # List roles
iamdelrole() { _confirm "Delete role $1? (policies must be removed first)" && aws iam delete-role --role-name "$1"; } # Delete role (confirm)
iamrename()  { _confirm "Rename user $1 to $2? Anything using the old name will break." && aws iam update-user --user-name "$1" --new-user-name "$2"; } # Rename user (confirm)

# ── CLOUDFRONT ────────────────────────────────────────────────────────────
alias cfls='aws cloudfront list-distributions'                   # List distributions
cfinval()  { aws cloudfront create-invalidation --distribution-id "$1" --paths "/*"; } # Invalidate all
cfwait()   { aws cloudfront wait distribution-deployed --id "$1"; } # Wait for deploy
cfwaitinv(){ aws cloudfront wait invalidation-completed --distribution-id "$1" --id "$2"; } # Wait for invalidation

# ── CLOUDWATCH LOGS ───────────────────────────────────────────────────────
alias logsg='aws logs describe-log-groups'                       # Log group names
logsshow()  { aws logs filter-log-events --log-group-name "$1" --start-time "$(( ($(date +%s) - ${2:-60} * 60) * 1000 ))" --no-paginate; } # Events from last N min (default 60)
logstail()  { aws logs tail "$1" --follow; }                     # Live-tail a log group (Ctrl+C to stop)
logsfields(){ aws logs get-log-group-fields --log-group-name "$1"; } # Available keys
logserr()   { aws logs filter-log-events --log-group-name "$1" --start-time "$(( ($(date +%s) - ${2:-60} * 60) * 1000 ))" --query "events[*].[message]" --filter-pattern "error" --output text --no-paginate; } # Errors from last N min (default 60)
logsdel()   { _confirm "Delete log group $1?" && aws logs delete-log-group --log-group-name "$1"; } # Delete log group (confirm)

# ── LAMBDA ────────────────────────────────────────────────────────────────
alias lsfn='aws lambda list-functions --query="Functions[*].[FunctionName,Timeout,MemorySize,LastModified]" --output table' # List functions
lfn()    { aws lambda get-function --function-name "$1"; }        # Function info
lfncfg() { aws lambda get-function-configuration --function-name "$1"; } # Function config
lfnenv() { _confirm "This REPLACES all env vars on $1. Continue?" && aws lambda update-function-configuration --function-name "$1" --environment "Variables=$2"; } # Replace ALL env vars (confirm)
lfninv() { aws lambda invoke --invocation-type RequestResponse --function-name "$1" "${2:-output.txt}"; } # Invoke
lfndel() { _confirm "Delete function $1 (all versions)?" && aws lambda delete-function --function-name "$1"; } # Delete function (confirm)
lfnver() { aws lambda list-versions-by-function --function-name "$1"; } # List versions
lfnpol() { aws lambda get-policy --function-name "$1"; }          # Show permissions

# ── CLOUDFORMATION ────────────────────────────────────────────────────────
alias cfnls='aws cloudformation describe-stacks --query "Stacks[*].[StackName,Outputs]"' # List stacks
cfntpl() { aws cloudformation get-template --stack-name "$1"; }   # Get template
cfnres() { aws cloudformation list-stack-resources --stack-name "$1"; } # List resources
cfncreate() { aws cloudformation create-stack --stack-name "$1" --capabilities CAPABILITY_IAM --template-body "file://$2"; } # Create stack
cfndel() { _confirm "Delete stack $1 and all its resources?" && aws cloudformation delete-stack --stack-name "$1"; } # Delete stack (confirm)

# ── SSM PARAMETER STORE ───────────────────────────────────────────────────
alias ssmls='aws ssm describe-parameters'                        # List parameters
ssmput() { _confirm "Overwrite parameter $1?" && aws ssm put-parameter --name "$1" --value "$2" --type "SecureString" --overwrite; } # Create/update encrypted param (confirm)
ssmget() { aws ssm get-parameter --name "$1" --with-decryption --query Parameter.Value --output text; } # Decrypt parameter (value only)
ssmcp()  { ssmget "$1" | tr -d '\n' | pbcopy && echo "Copied to clipboard"; } # Copy decrypted parameter, never shown
ssmdel() { _confirm "Delete parameter $1?" && aws ssm delete-parameter --name "$1"; } # Delete parameter (confirm)

# ── DYNAMODB ──────────────────────────────────────────────────────────────
alias ddbls='aws dynamodb list-tables'                            # List tables
ddbdesc()  { aws dynamodb describe-table --table-name "$1"; }     # Table properties
ddbscan()  { aws dynamodb scan --table-name "$1" --max-items "${2:-25}"; } # Scan first N items (default 25)
ddbscanall(){ aws dynamodb scan --table-name "$1"; }              # Scan ENTIRE table (slow/costly on big tables)
ddbcount() { aws dynamodb scan --table-name "$1" --select "COUNT"; } # Count items
ddbget()   { aws dynamodb get-item --table-name "$1" --key "$2"; } # Get item
ddbdel()   { _confirm "Delete item from $1?" && aws dynamodb delete-item --table-name "$1" --key "$2"; } # Delete item (confirm)
ddbput()   { aws dynamodb put-item --table-name "$1" --item "file://$2"; } # Insert item from file

# ── ECS ───────────────────────────────────────────────────────────────────
alias ecscl='aws ecs list-clusters'                               # List clusters
ecsinst()  { aws ecs list-container-instances --cluster "$1"; }   # List container instances
ecssvc()   { aws ecs list-services --cluster "$1"; }               # List services
ecstasks() { aws ecs list-tasks --cluster "$1"; }                  # List tasks
ecsdelsvc(){ _confirm "Delete service $2 in cluster $1?" && aws ecs delete-service --cluster "$1" --service "$2"; } # Delete service (confirm)
ecsdelcl() { _confirm "Delete cluster $1?" && aws ecs delete-cluster --cluster "$1"; } # Delete cluster (confirm)

# ── SNS ───────────────────────────────────────────────────────────────────
alias snsls='aws sns list-topics'                                 # List topics
snsnew()   { aws sns create-topic --name "$1"; }                   # Create topic
snsdel()   { _confirm "Delete topic $1?" && aws sns delete-topic --topic-arn "$1"; } # Delete topic (confirm)
snssub()   { aws sns subscribe --topic-arn "$1" --protocol "$2" --notification-endpoint "$3"; } # Subscribe
snsunsub() { aws sns unsubscribe --subscription-arn "$1"; }         # Unsubscribe
snssubls() { aws sns list-subscriptions-by-topic --topic-arn "$1"; } # List subscriptions

# ── SQS ───────────────────────────────────────────────────────────────────
alias sqsls='aws sqs list-queues'                                 # List queue URLs
sqsattr()  { aws sqs get-queue-attributes --attribute-names All --queue-url "$1"; } # Queue attributes
sqsrecv()  { aws sqs receive-message --attribute-names All --max-number-of-messages "${2:-10}" --queue-url "$1"; } # Receive messages
sqspurge() { _confirm "Purge ALL messages from $1?" && aws sqs purge-queue --queue-url "$1"; } # Purge queue (confirm)
sqssend()  { aws sqs send-message --queue-url "$1" --message-body "$2"; } # Send message

# ── SCHEDULED EVENTS ──────────────────────────────────────────────────────
eventsrate() { aws events put-rule --schedule-expression "rate($2)" --name "$1"; } # eventsrate myrule "5 minutes"
eventscron() { aws events put-rule --schedule-expression "cron($2)" --name "$1"; } # eventscron myrule "0 12 * * ? *"
eventsdel()  { _confirm "Delete rule $1?" && aws events delete-rule --name "$1"; } # Delete scheduled event (confirm)
eventsoff()  { aws events disable-rule --name "$1"; }              # Disable scheduled event
eventson()   { aws events enable-rule --name "$1"; }                # Enable scheduled event

# ── COST & BILLING ─────────────────────────────────────────────────────────
awscost() { # Month-to-date cost by service. Usage: awscost [start] [end] (YYYY-MM-DD)
    local start="${1:-$(date -v1d +%Y-%m-%d 2>/dev/null || date -d 'start of month' +%Y-%m-%d)}"
    # Cost Explorer's end date is exclusive, so default to tomorrow (includes today, works on the 1st)
    local end="${2:-$(date -v+1d +%Y-%m-%d 2>/dev/null || date -d tomorrow +%Y-%m-%d)}"
    aws ce get-cost-and-usage --time-period Start="$start",End="$end" \
        --granularity MONTHLY --metrics "UnblendedCost" \
        --group-by Type=DIMENSION,Key=SERVICE \
        --query "ResultsByTime[0].Groups[*].[Keys[0],Metrics.UnblendedCost.Amount]" --output table
}