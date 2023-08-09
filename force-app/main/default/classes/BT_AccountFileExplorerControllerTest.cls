/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Test Class: BT_AccountFileExplorerControllerTest
* Created by Sagar
*
* Test class for BT_AccountFileExplorerController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_AccountFileExplorerControllerTest {
    static testMethod void myUnitTest1() {
        BT_TestUtils.createFileExplorerConfiguration();
        Account testAccount = BT_TestUtils.createAccount();
        ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
        ApexPages.StandardController scon = new ApexPages.StandardController(testAccount);
        BT_AccountFileExplorerController con = new BT_AccountFileExplorerController(scon);
        System.assertEquals(con.strMainObjectFieldAPI, BT_Utils.getNamespacePrefix()+'Account__c');
        System.assertEquals(con.strMainObjectId, testAccount.Id);
        System.assertEquals(con.strOtherObjectFieldAPI, null);
        System.assertEquals(con.strOtherObjectId, null);
    }
}