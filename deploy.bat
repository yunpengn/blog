@ECHO OFF

rem Some messages before the deployment actually starts
echo Starting to deploy this blog website ...
echo Proudly powered by Hexo.js at https://hexo.io/ ...

rem Start to deploy the Hexo blog website via a Git repository
hexo deploy --generate

rem Prompt that the deployment is successful
echo Deployment successful.