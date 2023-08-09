//Count Number of Case records and populate on the Opportunity
Trigger CaseTrigger on Case (after insert, after update, after delete, after undelete, before insert) { 
    
     Organization org = [SELECT  IsSandbox FROM Organization limit 1];
     Box_Setting__mdt listOfboxsettings = [ SELECT Enable_Box_in_Sandbox__c FROM Box_Setting__mdt WHERE DeveloperName = 'Box_Setting'LIMIT 1 ];
    if(trigger.isBefore){
        
        for(Case c :trigger.new){
            if(c.RecordTypeId == '0120L0000009730'){ //Intelligence Case
                //  c.OwnerId = '005E0000005TNU1IAO';
                c.OwnerId = Label.Intelligence_Case;
            } else if(c.RecordTypeId == '012E0000000seQ0'){  //Field Service Support Case
                //  c.OwnerId = '00G0L000003pr0A';
                c.OwnerId = Label.Field_Service_Support_Case;
            } else if(c.RecordTypeId == '012E0000000oR5Z'){  //Engineering Case
                // c.OwnerId = '00GE0000003Yro3';
                c.OwnerId = Label.Engineering_Case;
            }
        }
        
    } else{
        List<Opportunity> UpdateOppList= new List<Opportunity>();
        Set<Id> Case_Id= new Set<Id>();
        
        if(Trigger.isDelete) {
            for(Case ct:Trigger.Old) {
                if(!String.isEmpty(ct.Opportunity__c)){
                    Case_Id.add(ct.Opportunity__c);   
                }    
            }   
        }
        else if(Trigger.isUpdate) {
            for(Case ct:Trigger.New) {
                if(!String.isEmpty(ct.Opportunity__c)){
                    Case_Id.add(ct.Opportunity__c);   
                }    
            }
            for(Case ct:Trigger.Old) {
                if(!String.isEmpty(ct.Opportunity__c)){
                    Case_Id.add(ct.Opportunity__c);   
                }
            } 
            CaseTriggerHelper.closeMilestonewhenCaseIsClosed(trigger.new,trigger.oldMap);
            CaseStatusChangeTriggerHandler.checkFieldUpdate(Trigger.new, Trigger.oldMap);
           
            if(!FeatureManagement.checkPermission('Disable_Box_Creation')){
              if(!org.IsSandbox || (listOfboxsettings.Enable_Box_in_Sandbox__c && org.IsSandbox)){
                CaseTriggerHelper.checkCaseForBoxFolderCreation(Trigger.new, Trigger.oldMap);
               }  
            }
        } 
        else{
            for(Case ct:Trigger.New) {
                if(!String.isEmpty(ct.Opportunity__c)){
                    Case_Id.add(ct.Opportunity__c);   
                }
            }
            CaseStatusChangeTriggerHandler.OnAfterInsert(Trigger.new);
            CaseStatusChangeTriggerHandler.OnAfterInsertOwner(Trigger.new);
            if(!FeatureManagement.checkPermission('Disable_Box_Creation')){
              if(!org.IsSandbox || (listOfboxsettings.Enable_Box_in_Sandbox__c && org.IsSandbox)){
               CaseTriggerHelper.checkCaseForBoxFolderCreation(Trigger.new,null);
              } 
            }
            
        }
        
        if(!Case_Id.isEmpty()){  
            // AggregateResult[] groupedResults = [SELECT COUNT(Id), Opportunity__c FROM Case where Opportunity__c IN :Case_Id GROUP BY Opportunity__c];
            AggregateResult[] groupedResults = [SELECT COUNT(Id), Opportunity__c FROM Case where Opportunity__c IN :Case_Id AND RecordType.Id !='0120v0000003LwX' AND Case.Opportunity__r.StageName IN ('Closed: Won','Booked','Partial Release','Released to Factory','Partial Shipment','Product Shipped','Invoiced')GROUP BY Opportunity__c];
            //Aggregation contains Count , opp-Id grouping by Opportunity__c
            System.debug('===groupedResults '+ groupedResults);
            for(AggregateResult ar:groupedResults) {
                
                Integer count = (INTEGER)ar.get('expr0'); //expr0 is Count, parsing into integer and storing in variable
                
                Id OppId= (ID)ar.get('Opportunity__c'); // Acc Id of that count
                System.debug('========> OPP ID '+ ar);
                Opportunity opp = new Opportunity(Id=OppId); // Fetching Opportunity of above Id to update count
                
                opp.Total_Number_of_Cases__c= count; // updating count for the retrieved Opportunity
                
                UpdateOppList.add(opp);
            }
        }
        
        if(!UpdateOppList.isEmpty()){
            //update UpdateOppList;
        }
    }
}