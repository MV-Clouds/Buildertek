/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class: BT_HomeControllerTest
* Created by Sagar: 26/05/2017
*
* - Test calss for BT_HomeController.

* - Modifications:
* - Sagar, 26/05/2017 – Initial Development
************************************************************************** */
@isTest
public class BT_HomeControllerTest {

    static testMethod void myUnitTest1() {
        BT_TestUtils.createFileExplorerConfiguration();
        ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
        ApexPages.CurrentPage().getParameters().put('mainObjectFieldAPI', 'Account__c');
        ApexPages.CurrentPage().getParameters().put('mainObjectId', 'a36rfgffg732145');
        ApexPages.CurrentPage().getParameters().put('otherObjectFieldAPI', 'Contact__c');
        ApexPages.CurrentPage().getParameters().put('otherObjectId', 'a36tfgffg732145');
        ApexPages.currentPage().getParameters().put('callerName', 'callePage');
        ApexPages.currentPage().getParameters().put('strExplorerConfigName', 'strExplorerConfigName');
        ApexPages.currentPage().getParameters().put('folderIdToLoad', 'folderId');
        BT_HomeController con = new BT_HomeController();
        System.assertEquals(con.retURL, '/home/home.jsp');
        System.assertEquals(con.strMainObjectFieldAPI, 'Account__c');
        System.assertEquals(con.strMainObjectId, 'a36rfgffg732145');
        System.assertEquals(con.strOtherObjectFieldAPI, 'Contact__c');
        System.assertEquals(con.strOtherObjectId, 'a36tfgffg732145');
        System.assertEquals(con.strCallerName, 'callePage');
    }        
}