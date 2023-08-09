/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Nov-2018
*/
@isTest
public class BT_ImportScheduleTest {
    
    public static testMethod void test1() {
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Testing Project';
        insert project;

    	buildertek__schedule__c sd = new buildertek__schedule__c();
    	sd.Description__c = 'test';
    	sd.Type__c = 'Master';
    	sd.Project__c = project.Id;
    	insert sd;
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(sd);
        BT_ImportSchedule testa = new BT_ImportSchedule(sc);
        testa.masterSchedules[0].isSelected = true;
        testa.save();
        
        Apexpages.currentPage().getParameters().put('Id', sd.Project__c);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<buildertek__Schedule__c>{sd});
	    stdSetController.setSelected(new List<buildertek__Schedule__c>{sd});
	    BT_ImportSchedule test = new BT_ImportSchedule(stdSetController);
	    System.assertEquals('Test','Test');
	 
    }
}