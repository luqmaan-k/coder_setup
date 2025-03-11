## First time login
1. Open up a browser and navigate to http://amcscoder.psgtech/
2. Enter your email id and the first time password is the same email id
![[login.png]]
3. Click on the square in the top right (highlighted green) and click on account settings (red)
![[afterlogin.png]]
4. In the security tab you should now be able to change your password
![[resetpassword.png]]
5. Next time you can use the new password that you set to login

## Workspaces
- They are generally small containers
- They come preinstalled with the required tools and libraries
- You can configure your workspace to your liking after creation

### How to create a workspace
1. You will need to figure out the right workspace for you
 - To do that navigate to the Templates tab as highlighted below
![[templates.png]]
2. To get more information about a template you can click on the template name and then navigate to the docs tab as highlighted below
![[templatedocs.png]]
3. Click on create workspace to create a workspace from the said template
4. Give the workspace a meaningful name (Like the LAB you are working in , or your projects name)
![[nameworkspace.png]]
5. You can always navigate back to a created workspace in the workspace tab
![[workspacetab.png]]

### Workspace status
- A workspace can have 4 statuses running,stopped,failed,pending
- To start a stopped workspace navigate to the workspace and click on start
![[stopped_workspace.png]]
- In case a workspace status is failed try restarting the workspace and if that doesnt work contact an admin
- A pending status means you have to wait in a queue for your turn to get your workspace started / stopped / deleted

### Deleting a Workspace
- Click on the 3 dots towards the top right as shown and click on the delete and follow the instructions
![[deleteworkspace.png]]
```
Warning !
Make sure to check the template docs to know the consequences of deleting a workspace as they can vary . 
Always make sure to keep backups of your code in another machine or github (or both)
```

## How to connect to a workspace
- Make sure the workspace is running and depending on the template used to create a workspace you will be given a list of **apps** that you can use to connect to workspace like below
- Click on the app that you would like to connect to the workspace with
![[workspaceapps.png]]
- Some applications are desktop applications ie : they connect directly to a desktop application if it is installed in the local machine like VS Code Desktop
- These apps will require you to click on a redirect link as show below
![[vscodedesktop.png]]
```
Note : after clicking on the link they may ask you to install an extension, follow the instructions after that.
If a connection didnt work try clicking on the app once more.
Some apps will take some time to establish a connection which may take a few minutes for the first time , they should ideally be faster for that workspace afterwards.
```
- Browser based apps will open a new browser window/tab with the application 
- By default most workspaces will have  a terminal browser app that can be used to open a terminal in the workspace to either work in or to debug any issues
## How to disconnect/logout

- #### Always log out if you are working in a lab
- #### Make sure to logout from a Desktop Application also

### How to logout
- Click on the square in the top right and logout
![[logout.png]]

### How to logout from VS Code Desktop
1. First close the remote connections to your workspace like highlighted below
	1. Click on area higlighted by an arrow below
	2. Click on close remote connection 
![[vscodelogout-close-connection.png]]
2. Click on the coder extension then on the 3 dots as higlighted and then logout
![[vscodelogout-1.png]]
