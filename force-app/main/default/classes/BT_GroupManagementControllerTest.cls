/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Controller Class:BT_GroupManagementControllerTest
* Created by Sagar
*
* - Test class for BT_GroupManagementController

* - Modifications:
* - Sagar - Initial Development
************************************************************************** */
@isTest
public with sharing class BT_GroupManagementControllerTest {
    static testMethod void testMethod1() {
        //create a user
        Profile p = [select id from profile where name = 'System Administrator'];
        User testUser = new User(alias='mausam12', email='sagar@thoriyas.com', 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username='aradmin123@72demo.com');
        insert testUser;
        
        //create Group
        Group testGroup = new Group();
        testGroup.Name = 'testGroup 786';
        insert testGroup;
        
        //add group member in Group
        GroupMember testGroupMember = new GroupMember();
        testGroupMember.GroupId = testGroup.Id;
        testGroupMember.UserOrGroupId = testUser.Id;
        insert testGroupMember;
        
        //Set Parameters
        ApexPages.currentPage().getParameters().put('selectedPublicGroupId', testGroup.Id+'');
        
        BT_GroupManagementController controller = new BT_GroupManagementController();
        
        String testGetTargetObjectType = controller.getTargetObjectType();
        System.assert(testGetTargetObjectType == 'Users');
        
        String testGetTargetObjectPickerConfigName = controller.getTargetObjectPickerConfigName();
        System.assert(testGetTargetObjectPickerConfigName == 'User Picker Tree');
        
        list<String> testGetTargetObjectPickerCheckableObjectTypes = controller.getTargetObjectPickerCheckableObjectTypes();
        System.assert(testGetTargetObjectPickerCheckableObjectTypes.size() == 1);
        
        Pagereference pgRef = controller.Cancel();
        System.assert(pgRef != null);
        
        //create treepickernode for user
        TreePickerNode testUserNode = new TreePickerNode(testUser.Id, testUser.Name, false);        
        testUserNode.checked = true; 
        List<TreePickerNode> testUserSelectedTreeNodes = new List<TreePickerNode>();
        testUserSelectedTreeNodes.add(testUserNode);
        //added one selected treepickernode
        controller.selectedUserNodes = testUserSelectedTreeNodes;  
        
        pgRef = controller.Save();
        System.assert(pgRef != null);
        controller.initializeGroupMembers();
    }
}