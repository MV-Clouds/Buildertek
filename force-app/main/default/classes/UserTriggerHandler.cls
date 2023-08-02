/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class: UserTriggerHandler
* Created by Sagar: 07/09/2017
*
* - Trigger Handler Class for User Trigger
* - Group member created as per users File Access Type
* - Modifications:
* - Sagar, 07/09/2017 – Initial Development
************************************************************************** */
public  class UserTriggerHandler {
    public static Boolean isSkipTrigger = false;
    /*
public void onAfterInsert(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers){
if(!isSkipTrigger){
// Create group member
manageGroupMembersForUsers(mapNewUsers, mapOldUsers);
// Manage permissionset assignment 
managePermissionSetAssignment(mapNewUsers, mapOldUsers);
}
}

public void onAfterUpdate(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers){
if(!isSkipTrigger){
// Create group member
manageGroupMembersForUsers(mapNewUsers, mapOldUsers);
// Manage permissionset assignment 
managePermissionSetAssignment(mapNewUsers, mapOldUsers);
}
}
*/
    /*
*   Purpose:    Assign/delete permission set as per users File Control User? field.
*   UnitTests:  
*/
    /*
public static void managePermissionSetAssignment(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers){
List<User> usersToRemovePermissionSet = new List<User>();
List<User> usersToAddPermissionSet = new List<User>();
List<Profile> s3LinkProfile = [Select Id From Profile Where Name = 'File Control User' LIMIT 1];
Id s3LinkProfileId;
if(!s3LinkProfile.isEmpty()){
s3LinkProfileId = s3LinkProfile[0].Id;
}
// Find groups for whom group memebership needs to be updated
for(User user : mapNewUsers.values()){
if(mapOldUsers == null || user.ProfileId != mapOldUsers.get(user.Id).ProfileId || user.Is_File_Control_User__c != mapOldUsers.get(user.Id).Is_File_Control_User__c){
if(mapOldUsers != null && mapOldUsers.get(user.Id) != null){
if(user.ProfileId == s3LinkProfileId){
usersToRemovePermissionSet.add(user);
} else if(!user.Is_File_Control_User__c){
usersToRemovePermissionSet.add(user);
}
}
if(user.ProfileId != s3LinkProfileId && user.Is_File_Control_User__c){
usersToAddPermissionSet.add(user);
}
}
}

// Get permission set used to grant access for File Control
List<PermissionSet> permissionSetForS3LinkAccess = [Select Id From PermissionSet Where Name = 'File_Control_User'];
if(!permissionSetForS3LinkAccess.isEmpty()){
if(!usersToRemovePermissionSet.isEmpty()){
// PermissionSetAssignment to delete
List<PermissionSetAssignment> permissionSetsToDelete = new List<PermissionSetAssignment>();
// Get permission set assignment to delete
permissionSetsToDelete  = [Select Id From PermissionSetAssignment Where PermissionSetId =:permissionSetForS3LinkAccess[0].Id AND AssigneeId IN:usersToRemovePermissionSet];
if(!permissionSetsToDelete.isEmpty()){
delete permissionSetsToDelete;
}
}

if(!usersToAddPermissionSet.isEmpty()){
// PermissionSetAssignment to create
List<PermissionSetAssignment> permissionSetsToInsert = new List<PermissionSetAssignment>();
// Users for which permission set is already assigned
Set<Id> userIddsForWhichPermissionSetIsAlreadyAssigned = new Set<Id>();
// Get existing permission set assignment
for(PermissionSetAssignment existingPermissionSet : [Select Id, AssigneeId From PermissionSetAssignment Where PermissionSetId =:permissionSetForS3LinkAccess[0].Id]){
userIddsForWhichPermissionSetIsAlreadyAssigned.add(existingPermissionSet.AssigneeId);
}
for(User user : usersToAddPermissionSet){
if(!userIddsForWhichPermissionSetIsAlreadyAssigned.contains(user.Id)){
permissionSetsToInsert.add(new PermissionSetAssignment(PermissionSetId = permissionSetForS3LinkAccess[0].Id, AssigneeId = user.Id));
}
}
insert permissionSetsToInsert;
}
}
}
*/
    /*
*   Purpose:    Creates group members as per users file access typr.
*   UnitTests:  
*/
    /*
public static void manageGroupMembersForUsers(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers){
// Create group member for users as per file access type
List<GroupMember> groupMembersToDelete = new List<GroupMember>();
List<GroupMember> groupMembersToInsert = new List<GroupMember>();
// Group by name
Map<String, Group> groupByName = new Map<String, Group>();
for(Group userGroup : [Select Id, Name, DeveloperName From Group Where DeveloperName = 'Users_with_Access_for_File_Control' OR DeveloperName = 'Grant_Read_Only_Access_For_Files' OR DeveloperName = 'Grant_Read_Write_Access_for_Files']){
groupByName.put(userGroup.DeveloperName, userGroup);
}
// Users membership by group name
Map<Id,Map<String, GroupMember>> groupMembersByGroupNameByUserId = new Map<Id,Map<String, GroupMember>>();
for(GroupMember groupMember : [Select Id, UserOrGroupId, Group.DeveloperName From GroupMember Where UserOrGroupId in :mapNewUsers.keySet()]){
Map<String, GroupMember> groupMembersByGroupName = groupMembersByGroupNameByUserId.get(groupMember.UserOrGroupId);
if(groupMembersByGroupName == null){
groupMembersByGroupName = new Map<String, GroupMember>();
}
groupMembersByGroupName.put(groupMember.Group.DeveloperName, groupMember);
groupMembersByGroupNameByUserId.put(groupMember.UserOrGroupId, groupMembersByGroupName);
}
// Find groups for whom group memebership needs to be updated
for(User user : mapNewUsers.values()){
Set<String> groupsNeedsToRemove = new Set<String>();
Set<String> groupsNeedsToAdd = new Set<String>();
if(mapOldUsers == null || (user.File_Access_Type__c != mapOldUsers.get(user.Id).File_Access_Type__c)){
if(mapOldUsers != null && mapOldUsers.get(user.Id) != null){
if(mapOldUsers.get(user.Id).File_Access_Type__c == BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY){
groupsNeedsToRemove.add('Grant_Read_Only_Access_For_Files');
} else if(mapOldUsers.get(user.Id).File_Access_Type__c == BT_Constants.FILE_ACCESS_PUBLIC_WRITE){
groupsNeedsToRemove.add('Grant_Read_Write_Access_for_Files');  
}
}
if(user.File_Access_Type__c == BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY){
groupsNeedsToAdd.add('Grant_Read_Only_Access_For_Files');
} else if(user.File_Access_Type__c == BT_Constants.FILE_ACCESS_PUBLIC_WRITE){
groupsNeedsToAdd.add('Grant_Read_Write_Access_for_Files');
}
}
if(mapOldUsers == null || (user.Is_File_Control_User__c != mapOldUsers.get(user.Id).Is_File_Control_User__c)){
if(mapOldUsers != null && mapOldUsers.get(user.Id) != null){
if(mapOldUsers.get(user.Id).Is_File_Control_User__c){
groupsNeedsToRemove.add('Users_with_Access_for_File_Control');
}
}
if(user.Is_File_Control_User__c){
groupsNeedsToAdd.add('Users_with_Access_for_File_Control');
}
}
if(groupMembersByGroupNameByUserId.get(user.Id) != null && !groupsNeedsToRemove.isEmpty()){
for(string groupNeedsToRemove : groupsNeedsToRemove){
if(groupMembersByGroupNameByUserId.get(user.Id).get(groupNeedsToRemove) != null){
groupMembersToDelete.add(groupMembersByGroupNameByUserId.get(user.Id).get(groupNeedsToRemove));
}
}
}

if(!groupsNeedsToAdd.isEmpty()){
for(String groupNeedsToAdd : groupsNeedsToAdd){
if(groupNeedsToAdd != null && groupByName.get(groupNeedsToAdd) != null){
groupMembersToInsert.add(new GroupMember(GroupId = groupByName.get(groupNeedsToAdd).Id, UserOrGroupId = user.Id));
}
}
}
}
// Delete group membership
if(Schema.sObjectType.GroupMember.isDeletable() && !groupMembersToDelete.isEmpty()){
delete groupMembersToDelete;
}
// Create group membership
if(!groupMembersToInsert.isEmpty() && Schema.sObjectType.GroupMember.isCreateable() && Schema.sObjectType.GroupMember.isUpdateable()){
if(Schema.sObjectType.GroupMember.isCreateable() && Schema.sObjectType.GroupMember.isUpdateable()){
upsert groupMembersToInsert;
}
}
}
*/
    
    
    public void isAfterInsert(list<User> oldUserValues , list<User> newUserValues,  Map<ID, User> newUserMap,  Map<ID, User> oldUserMap){
        string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
            'FROM User Where Id IN:newUserValues';    
        list<User> usersList = Database.query(strQry);
        
        List<String> userIds = new List<String>();
        
        if(usersList.size() > 0){
            for(User usr: usersList){
                userIds.add(usr.Id);
            } 
        }
        
        List<String> VendorIds = new List<String>();
        if(usersList.size() > 0){
            for(User usr: usersList){
                VendorIds.add(usr.AccountId);
            }
        }
        system.debug('usersList---->'+usersList);
        system.debug('VendorIds----------->'+VendorIds);
        
        
        giveShareAccessToSOV(userIds,VendorIds);
        
        
    }
    
    
    @future
    public static void giveShareAccessToSOV(List<String> userIds, List<String> VendorIds){
        
        system.debug('userIds------>'+userIds);
        
        system.debug('VendorIds----->'+VendorIds);
        
        
        string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
            'FROM User Where Id IN:userIds';    
        list<User> usersList = Database.query(strQry);
        
        
        system.debug('usersList------->'+usersList);
        
        list<buildertek__Schedule_of_Values__c>  SOVRec = new list<buildertek__Schedule_of_Values__c>();
        if(VendorIds.size() > 0){
            SOVRec  = [select Id, name, buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c, buildertek__Vendor__c from buildertek__Schedule_of_Values__c where buildertek__Vendor__c IN: VendorIds AND (recordtype.name = 'Vendor' OR recordtype.name = 'Master' ) LIMIT 10000];
        }
        system.debug('SOVRec--------->'+SOVRec);
        
         List<buildertek__Schedule_of_Values__Share> rfqshareList=new List<buildertek__Schedule_of_Values__Share>();
        
        if(SOVRec.size()>0){
            for (buildertek__Schedule_of_Values__c rfqVendor : SOVRec){
                for(User usr1: usersList){
                    system.debug('usrrec--->'+usersList ); 
                    if(rfqVendor.recordtype.name == 'Vendor' &&  rfqVendor.buildertek__Status__c == 'Company Submitted' && rfqVendor.buildertek__Vendor__c != null){
                        system.debug(rfqVendor.buildertek__Vendor__c);
                        system.debug(usr1.AccountId);
                        if(rfqVendor.buildertek__Vendor__c == usr1.AccountId){
                            buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                            rfqshare.ParentId= rfqVendor.Id;
                            rfqshare.UserOrGroupId=usr1.Id;
                            rfqshare.AccessLevel= 'Edit';
                            rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                            rfqshareList.add(rfqshare);
                            system.debug('rfqshare--->'+rfqshare); 
                        } 
                    }
                    
                    else if(rfqVendor.recordtype.name == 'Master'){
                        system.debug(rfqVendor.buildertek__Vendor__c);
                        system.debug(usr1.AccountId);
                        if(rfqVendor.buildertek__Vendor__c == usr1.AccountId || rfqVendor.buildertek__Vendor__c == null){
                            buildertek__Schedule_of_Values__Share rfqshare=new buildertek__Schedule_of_Values__Share();
                            rfqshare.ParentId= rfqVendor.Id;
                            rfqshare.UserOrGroupId=usr1.Id;
                            rfqshare.AccessLevel= 'Edit';
                            rfqshare.RowCause=Schema.buildertek__Schedule_of_Values__Share.RowCause.Manual;             
                            rfqshareList.add(rfqshare);
                            system.debug('rfqshare--->'+rfqshare); 
                        } 
                    } 
                } 
            }
            system.debug('rfqshareList -------> '+rfqshareList);
            if(rfqshareList.size()>0){
                Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
            }
        }
        
        
    }
    
    
    
    
    
}