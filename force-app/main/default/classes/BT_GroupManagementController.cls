/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Controller Class:BT_GroupManagementController
* Created by Sagar
*
* - Group Member management

* - Modifications:
* - Sagar - Initial Development
************************************************************************** */
public with sharing class BT_GroupManagementController {
    public Boolean isError{get; set;}   
    public list<Group> allGroups {get; set;}
    String selectedPublicGroupId;
    public Boolean showEditPublicGroupPopup {get; set;}
    public Group selectedPublicGroup {get; set;}
    public List<TreePickerNode> selectedUserNodes {get;set;}
    public List<String> searchableObjectTypes{get; set;}
    
    public BT_GroupManagementController() {
        searchableObjectTypes = new List<String>{'User'};
        selectedUserNodes = new List<TreePickerNode>();
        
        selectedPublicGroupId = ApexPages.currentPage().getParameters().get('selectedPublicGroupId').escapeHtml4(); 
        if(Schema.sObjectType.Group.fields.id.isAccessible()
            && Schema.sObjectType.Group.fields.Name.isAccessible()
            && Schema.sObjectType.Group.fields.createdDate.isAccessible()
            && Schema.sObjectType.Group.fields.createdById.isAccessible()
            && Schema.sObjectType.User.fields.Name.isAccessible()){
            
            allGroups = [SELECT Id, Name, createdById, CreatedBy.Name, createdDate FROM Group WHERE type = 'Regular'];
        }
        
        
        if(selectedPublicGroupId != null) {
            if(Schema.sObjectType.Group.fields.id.isAccessible()
                && Schema.sObjectType.Group.fields.Name.isAccessible()){
                
                selectedPublicGroup = [SELECT Id, Name FROM Group WHERE Id =: selectedPublicGroupId];
            }
        }
    }
    
    public String getTargetObjectType() {        
        return BT_Constants.TREE_TYPE_USER;
    }
    
    public String getTargetObjectPickerConfigName() {        
        return 'User Picker Tree';
    }
    
    public List<String> getTargetObjectPickerCheckableObjectTypes() {
        List<String> checkableNodes = new List<String>();
        checkableNodes.add('User');
        return checkableNodes;
    }
    
    public PageReference Cancel() {
        return new PageReference('/home/home.jsp');
    }


    public PageReference Save() {
        SavePoint sp = Database.setSavePoint();
        try {
            list<GroupMember> newGroupMembers = new list<GroupMember>();
            // Prepare set of existing group members
            Set<Id> existingGroupMembers = new Set<Id>();
            List<GroupMember> GroupMemberList;
            if(Schema.sObjectType.GroupMember.fields.UserOrGroupId.isAccessible()
                && Schema.sObjectType.GroupMember.fields.GroupId.isAccessible()){
                GroupMemberList = [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE GroupId =: selectedPublicGroup.Id];
            }
            for(GroupMember existingGroupMember : GroupMemberList) {
                existingGroupMembers.add(existingGroupMember.UserOrGroupId);
            }
            // Prepare set selected group members to remove existing group members which are not selected
            Set<Id> selectedGroupMembers = new Set<Id>();
            for(TreePickerNode selectedUserNode : selectedUserNodes) {
                // Check for duplicate and add group member
                if(!existingGroupMembers.contains(selectedUserNode.Id)) {
                    GroupMember newGroupMember = new GroupMember();
                    newGroupMember.GroupId = selectedPublicGroup.Id;
                    newGroupMember.UserOrGroupId = selectedUserNode.Id;
                    newGroupMembers.add(newGroupMember);
                }
                selectedGroupMembers.add(selectedUserNode.Id);
            }
            if(!newGroupMembers.isEmpty()){
                DMLManager.insertAsUser(newGroupMembers);
            }
            // Remove group member which are not selected from group
            List<GroupMember> groupMembersToDelete = new List<GroupMember>();
            List<GroupMember> selectedGroupMembersList;
            if(Schema.sObjectType.GroupMember.fields.UserOrGroupId.isAccessible()
                && Schema.sObjectType.GroupMember.fields.GroupId.isAccessible()){
                selectedGroupMembersList = [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId NOT IN :selectedGroupMembers];        
            }
            for(GroupMember gm : selectedGroupMembersList){
                if(!String.valueOf(gm.UserOrGroupId).startsWith('00G')){
                    groupMembersToDelete.add(gm);
                }
            }
            if(!groupMembersToDelete.isEmpty()){
                DMLManager.deleteAsUser(groupMembersToDelete);
            }
            
            return new PageReference('/home/home.jsp');
        } catch(Exception ex){
            Database.rollback(sp);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return null;
        }
    } 
    
    public void initializeGroupMembers(){
        try{
            User currentUser;
            if(Schema.sObjectType.User.fields.id.isAccessible()
                && Schema.sObjectType.Profile.fields.Name.isAccessible()){
                    
                currentUser = [Select Id, Profile.Name From User Where Id = :UserInfo.getUserId() LIMIT 1];    
            }
            
            if(currentUser.Profile.Name != 'System Administrator'){
                throw new BT_ApplicationException(System.Label.Group_Management_Access_Error);
            }
            if(selectedPublicGroupId == null || selectedPublicGroupId.length() == 0){
                throw new BT_ApplicationException(System.label.Group_Id_Missing_Error);
            }
        } catch(Exception e){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return;
        }
        List<User> groupMembers;
        if(Schema.sObjectType.User.fields.id.isAccessible()
            && Schema.sObjectType.User.fields.name.isAccessible()
            && Schema.sObjectType.User.fields.UserType.isAccessible()
            && Schema.sObjectType.GroupMember.fields.UserorGroupId.isAccessible()){
                
            groupMembers = [Select u.Id, u.name, u.UserType From User u where u.isActive = true and u.id in (SELECT gm.UserorGroupId from GroupMember gm where gm.Group.Id =: selectedPublicGroupId) order by name];    
        }
        
        
        for(User groupMember : groupMembers){
            selectedUserNodes.add(new TreePickerNode(groupMember.Id, groupMember.name));
        }
    }
}