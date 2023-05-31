# metabase_ecs

## usage

1. docker-compose up
```zsh
% docker-compose up -d
```

2. open <a href="localhost:3000">localhost:3000</a>


```
aws ssm put-parameter \
    --name "/metabase/rds/mysql/username" \
    --description "rds username" \
    --value "xxxxx" \
    --type String

aws ssm put-parameter \
    --name "/metabase/rds/mysql/password" \
    --description "rds password" \
    --value "xxxxxxxxxxxx" \
    --type SecureString
```
