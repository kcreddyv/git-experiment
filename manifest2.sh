#!/bin/bash -x
manifest_file="$1"
function usage() {
echo """$0 <manifest_file>""" >&2
}
manifest() {
if [ "$manifest_file" == "manifest2.json" ]; then
echo "valid manifest file"
else
echo "invalid manifest file"
exit 1
fi
}
if [ "$manifest_file" == "" ]; then
usage 
exit 1
fi
manifest
#getting length of json
if [ -f "$manifest_file" ]; then
project_name=$(jq -r '.project_name' $manifest_file)
version=$(jq -r '.version' $manifest_file)
destinationpath=$(jq -r '.destination | .s3_path' $manifest_file) 
componentlength=$(jq -r '.component | length' $manifest_file)
i=$(($componentlength-1))
for((m=0; m<=i; m++))
do
reponame=$(jq -r --arg m "$m" '.component | .['$m'] | .git_repo_name' $manifest_file)
git clone $version git@github.com:kcreddyv/$reponame.git $reponame
sourcelength=$(jq -r --arg m "$m" '.component | .['$m'] | .src | length' $manifest_file)
k=$(($sourcelength-1))
for ((n=0; n<=k; n++))
do
path=$(jq -r --arg m "$m" --arg n "$n" '.component | .['$m'] | .src['$n'] | .path' $manifest_file)
filelength=$(jq -r --arg m "$m" --arg n "$n" '.component | .['$m'] | .src['$n'] | .files | length' $manifest_file)
l=$(($filelength-1))
for (( p=0; p<=l; p++))
do
file=$(jq -r --arg m "$m" --arg n "$n" --arg p "$p" '.component | .['$m'] | .src['$n'] | .files['$p']' $manifest_file)
mkdir -p $version/$reponame/$path
cp -r $reponame/$path/$file $version/$reponame/$path
done
done
done
fi
