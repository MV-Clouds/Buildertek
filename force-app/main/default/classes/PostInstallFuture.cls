/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Post Intall Class: PostInstallFuture 
* Created by Sagar
*
* - All future method for postinstall

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public without sharing class PostInstallFuture {
    /*
    *   Purpose:    Required Create Groups and Group Members.
    *   Parameters: 
    *   UnitTests:  
    */
    @future
    public static void createRequiredGroupsOnPackageInstall(){
        // No need to run if this is not an upgrade or patch
        Map<String, Group> groupByDeveloperName = new Map<String, Group>();
        for(Group grp : [Select Id, Name, DeveloperName From Group Where DeveloperName = 'Grant_Read_Only_Access_For_Files' OR DeveloperName = 'Grant_Read_Write_Access_for_Files' OR DeveloperName = 'Users_with_Access_for_File_Control']){
            groupByDeveloperName.put(grp.DeveloperName, grp);
        }
        if(groupByDeveloperName.get('Grant_Read_Write_Access_for_Files') == null){
            Group groupForUsersWithWriteAccess = new Group();
            groupForUsersWithWriteAccess.Name = 'Users with Read/Write Access for Files';
            groupForUsersWithWriteAccess.DeveloperName = 'Grant_Read_Write_Access_for_Files';
            groupByDeveloperName.put(groupForUsersWithWriteAccess.DeveloperName, groupForUsersWithWriteAccess);
        }
        if(groupByDeveloperName.get('Grant_Read_Only_Access_For_Files') == null){
            Group groupForUsersWithReadAccess = new Group();
            groupForUsersWithReadAccess.Name = 'Users with Read Only Access for Files';
            groupForUsersWithReadAccess.DeveloperName = 'Grant_Read_Only_Access_For_Files';
            groupByDeveloperName.put(groupForUsersWithReadAccess.DeveloperName,groupForUsersWithReadAccess);
        }
        if(groupByDeveloperName.get('Users_with_Access_for_File_Control') == null){
            Group groupForS3LinkUsers = new Group();
            groupForS3LinkUsers.Name = 'Users with Access for File Control';
            groupForS3LinkUsers.DeveloperName = 'Users_with_Access_for_File_Control';
            groupByDeveloperName.put(groupForS3LinkUsers.DeveloperName,groupForS3LinkUsers);
        }
        if(!groupByDeveloperName.values().isEmpty()){
            if(Schema.sObjectType.Group.fields.id.isCreateable() && Schema.sObjectType.Group.fields.Name.isCreateable() && Schema.sObjectType.Group.fields.DeveloperName.isCreateable() &&
                Schema.sObjectType.Group.fields.id.isUpdateable() && Schema.sObjectType.Group.fields.Name.isUpdateable() && Schema.sObjectType.Group.fields.DeveloperName.isUpdateable() ){
                upsert groupByDeveloperName.values();
            }
        }
        List<GroupMember> groupMembers;
         if(Schema.sObjectType.GroupMember.fields.Id.isAccessible()&&
            Schema.sObjectType.GroupMember.fields.UserOrGroupId.isAccessible() &&
			Schema.sObjectType.Group.fields.DeveloperName.isAccessible()
			){
            groupMembers = [Select Id, UserOrGroupId, Group.DeveloperName From GroupMember Where UserOrGroupId =: groupByDeveloperName.get('Grant_Read_Write_Access_for_Files').Id AND Group.DeveloperName = 'Grant_Read_Only_Access_For_Files'];
			}
        if(groupMembers.isEmpty()){
        // 	if(Schema.sObjectType.GroupMember.isCreateable()){
        	    if(Schema.sObjectType.GroupMember.fields.GroupId.isCreateable() && Schema.sObjectType.GroupMember.fields.UserOrGroupId.isCreateable() ){
            	    insert new GroupMember(UserOrGroupId = groupByDeveloperName.get('Grant_Read_Write_Access_for_Files').Id, GroupId = groupByDeveloperName.get('Grant_Read_Only_Access_For_Files').Id);
        	    }
        // 	}
        }
    }
    
    /*
    *   Executed:   Start schedule job for presigned URL.
    *   Parameters: 
    *   UnitTests:  
    */
    @future
    public static void startScheduleJobForPresignedURLs(){
        // Create save point
        Savepoint sp = Database.setSavepoint();
        try {
            List<CronTrigger> presignedURLScheduleJobs;
            if(Schema.sObjectType.CronTrigger.fields.Id.isAccessible()&&
            Schema.sObjectType.CronTrigger.fields.CronJobDetailId.isAccessible() &&
			Schema.sObjectType.CronJobDetail.fields.Id.isAccessible()  &&
			Schema.sObjectType.CronJobDetail.fields.Name.isAccessible() &&
			Schema.sObjectType.CronJobDetail.fields.JobType.isAccessible()
			){
             presignedURLScheduleJobs = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name Like '%URL%'];
			}
        	if(presignedURLScheduleJobs.isEmpty()){
        		BT_GeneratePresignedURLSchedulable presignedURLSchedulable  = new BT_GeneratePresignedURLSchedulable();
    			String cronExpressoin = '0 0 0 * * ?';
    			System.schedule('Update Pre-signed URL', cronExpressoin, presignedURLSchedulable);
        	}
        } catch(Exception ex) {
            Database.rollback(sp);
            BT_Utils.sendJobFailureEmail('Future Job Failed: Start schedule job for Presigned URL', 'Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause());
        }
    }
    
    /*
    *   Executed:   Replace "Salesforce Access Type" with new values.
    *   Parameters: 
    *   UnitTests:  
    */
    @future
    public static void setAccessTypeForUsers(){
        // Create save point
        Savepoint sp = Database.setSavepoint();
        try {
            list<User> s3LinkUsers;
            if(Schema.sObjectType.User.fields.Id.isAccessible()&&
            Schema.sObjectType.User.fields.Name.isAccessible() &&
			Schema.sObjectType.User.fields.File_Access_Type__c.isAccessible()  ){
             s3LinkUsers = [Select Id, Name, File_Access_Type__c From User Where File_Access_Type__c = 'Public Read Only' OR File_Access_Type__c = 'Public Write'];
			}
            if(!s3LinkUsers.isEmpty()){
                for(User user : s3LinkUsers){
                    if(user.File_Access_Type__c == 'Public Read Only'){
                    	user.File_Access_Type__c = BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY;
                	} else if(user.File_Access_Type__c == 'Public Write'){
                		user.File_Access_Type__c = BT_Constants.FILE_ACCESS_PUBLIC_WRITE;
                	}
                }
                UserTriggerHandler.isSkipTrigger = true;
                if(Schema.sObjectType.User.isUpdateable() &&
	                Schema.sObjectType.User.fields.File_Access_Type__c.isUpdateable()){
                   update s3LinkUsers;
	                }
                UserTriggerHandler.isSkipTrigger = false;
            }
        } catch(Exception ex) {
            //rollback to save point
            Database.rollback(sp);
            BT_Utils.sendJobFailureEmail('Future Job Failed: Reset Salesforce Access Type for Users', 'Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause());
        }
    }
}