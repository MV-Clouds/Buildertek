/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* PostInstall Batchable Class: BT_PostInstallBatchableTask1
* Created by Sagar: 17/09/2017
*
* - Update users "File Access Type" as per the group membership

* - Modifications:
* - Sagar, 17/09/2017 – Initial Development
************************************************************************** */
global with sharing class BT_PostInstallBatchableTask1 implements Database.Batchable<sObject> {
    global BT_PostInstallBatchableTask1 () {
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // Get all users 
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    }
    
    global void finish(Database.BatchableContext BC){
    }
}