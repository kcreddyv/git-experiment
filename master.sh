#!/bin/bash
manifest_file="$1"
function usage() {
echo """$0 <manifest_file>""" >&2
}
manifest() {
if [ "$manifest_file" == "sample-manifest-raw-ink.json" ] || [ "$manifest_file" == "sample-manifest-raw-laser.json" ] || [ "$manifest_file" == "sample-manifest-raw-wpp.json" ]; then
echo "valid manifest file"
else
echo "invalid manifest file"
exit 1
fi
}
function error() {
echo """error: $1""" >&2
exit 1
}
if [ "$manifest_file" == "" ];then
usage
exit 1
fi
manifest
if [ -f "$manifest_file" ]; then
git clone -b dev-int git@github.azc.ext.hp.com:krishna-vuyyuru/git-experiment.git
#here we use release branch or release tag instead of dev-int 
cd git-experiment
git checkout -b master origin/master
git checkout dev-int #checkout in to release branch or tag
cd ..
#getting length of manifest_file
length=`cat $manifest_file | jq 'length'`
echo $length
k=$(($length-1))
echo $k
for ((n=0 ; n<=$k; n++))
do
echo $n
repo=$(cat $manifest_file | jq -r --arg n "$n" '.['$n'] | .repo')
component=$(cat $manifest_file | jq -r --arg n "$n" '.['$n'] | .component')
directory=$(cat $manifest_file | jq -r --arg n "$n" '.['$n'] | .directory')
cd $repo
git checkout master
git checkout dev-int --  $component/$directory #checkout the components from release branch using manifest file
git add *
git commit -m "something"
git checkout dev-int #here we will checkout release branch
cd ..
done
cd $repo
git checkout master
#git tag $releaseversion
#git push origin master
#git push origin --tags
fi
