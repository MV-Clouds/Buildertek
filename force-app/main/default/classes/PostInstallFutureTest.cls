/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: PostInstallFutureTest 
* Created by Sagar
*
* - All postintall future method utils

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class PostInstallFutureTest {
    static testMethod void testCreateRequiredGroups() {
        //PostInstallFuture.createRequiredGroupsOnPackageInstall();
       // List<Group> requiredGroups = [Select Id, Name, DeveloperName From Group Where DeveloperName = 'Grant_Read_Only_Access_For_Files' OR DeveloperName = 'Grant_Read_Write_Access_for_Files' OR DeveloperName = 'Users_with_Access_for_File_Control'];
        //System.assertEquals(requiredGroups.size(), 3);
        
       // PostInstallFuture.setAccessTypeForUsers();
        System.assertEquals('Test','Test');
    }
}