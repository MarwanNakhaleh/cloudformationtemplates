bucketname=$1
projectname=$2
s3stackname=$3

# S3 stack
create_output=$(aws cloudformation create-stack --stack-name "$s3stackname" --template-body file://s3.yml --parameters ParameterKey=NameOfBucket,ParameterValue=$bucketname ParameterKey=ProjectName,ParameterValue=$projectname)
if echo $create_output | grep 'already exists'; then
    echo "Stack already exists."
    exit 0
elif echo "$create_output" | grep 'StackId'; then
    echo "Waiting for $s3stackname to finish creation..."
    aws cloudformation wait stack-create-complete --stack-name $s3stackname
    aws s3 sync ./files_for_website s3://"$bucketname"/

    echo "http://$bucketname.s3-website-us-east-1.amazonaws.com"
    echo "Finished create/update successfully!"
else
    echo "Unable to create stack"
    echo $create_output
fi

