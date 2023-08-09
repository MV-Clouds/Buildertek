public with sharing class BTCreateMasterSOVController {
    public BTCreateMasterSOVController() {

    }

    
    @AuraEnabled
    public static  List<SOVWrapper>  getSOVs(){       
        
        List<SOVWrapper> SOVWrapperList = new List<SOVWrapper>();        
        list<buildertek__Schedule_of_Values__c> sovsList = [ SELECT Id,
                                                        Name, buildertek__Project__c, 
                                                        buildertek__Project__r.Name,
                                                         buildertek__Date_Submitted__c, 
                                                         buildertek__Status__c 
                                                         FROM buildertek__Schedule_of_Values__c  
                                                         where  buildertek__Status__c='Vendor Submitted'   
                                                        ];
        integer i=1;
        
        if(sovsList.size() > 0){
            for(buildertek__Schedule_of_Values__c rec : sovsList){
                SOVWrapper obj = new SOVWrapper();
                obj.RowNumber = i;
                obj.RecordId = rec.Id;
                system.debug(obj.RecordId); 
                obj.Name = rec.Name;
                obj.Project = rec.buildertek__Project__r.Name;
                obj.DateSubmitted = rec.buildertek__Date_Submitted__c;
                obj.Status = rec.buildertek__Status__c;                
                SOVWrapperList.add(obj);          
                i++;
            }
        }   
        system.debug(SOVWrapperList.size());
        return SOVWrapperList;
        
    }
    
    
    public class SOVWrapper{
        @AuraEnabled public Integer RowNumber;
        @AuraEnabled public Id RecordId;
        @AuraEnabled public String Name;
        @AuraEnabled public String Project;
        @AuraEnabled public String Type;
        @AuraEnabled public Datetime DateSubmitted;
        @AuraEnabled public String Status; 
        @AuraEnabled public boolean isChecked=false; 
    } 
    
    
    @AuraEnabled
    public static  List<SOVLinesWrapper>  getSOVLines(list<Id> sovids){       
        system.debug('sovids--->'+sovids);
        List<SOVLinesWrapper> SOVLinesWrapperList = new List<SOVLinesWrapper>();        
        list<buildertek__Schedule_of_Value_Lines__c> sovlinesList = [ SELECT Id, Name, 
        buildertek__Scheduled_Value__c, buildertek__Schedule_of_Values__c,
        buildertek__Schedule_of_Values__r.Name, 
        buildertek__Item__c, buildertek__Description_of_Work__c 
        FROM buildertek__Schedule_of_Value_Lines__c
        where  buildertek__Schedule_of_Values__c In:sovids
        ];

        integer i=1;
        
        if(sovlinesList.size() > 0){
            for(buildertek__Schedule_of_Value_Lines__c rec : sovlinesList){
                SOVLinesWrapper obj = new SOVLinesWrapper();
                obj.RowNumber = i;
                obj.RecordId = rec.Id;
                system.debug(obj.RecordId); 
                obj.Name = rec.Name;
                obj.ScheduleValue = rec.buildertek__Scheduled_Value__c;
                obj.ScheduleOfValues = rec.buildertek__Schedule_of_Values__r.Name;
                obj.Item = rec.buildertek__Item__c;
                obj.Description = rec.buildertek__Description_of_Work__c;                
                SOVLinesWrapperList.add(obj);          
                i++;
            }
        }   
        system.debug(SOVLinesWrapperList.size());
        return SOVLinesWrapperList;
        
    }
    
    
    public class SOVLinesWrapper{
        @AuraEnabled public Integer RowNumber;
        @AuraEnabled public Id RecordId;
        @AuraEnabled public String Name;
        @AuraEnabled public decimal ScheduleValue;
        @AuraEnabled public String ScheduleOfValues;
        @AuraEnabled public String Item;
        @AuraEnabled public String Description;
    } 

    @AuraEnabled
    public static string createMasterSOV(string recId,list<Id> sovlineids, list<string> sovIds){       
        system.debug('recId--->'+recId);
        system.debug('sovlineids--->'+sovlineids);
        list<buildertek__Schedule_of_Value_Lines__c> sovlinesList = [ SELECT Id, Name, 
        buildertek__Scheduled_Value__c, buildertek__Schedule_of_Values__c,
        buildertek__Schedule_of_Values__r.Name, 
        buildertek__Schedule_of_Values__r.buildertek__Status__c,
        buildertek__Item__c, buildertek__Description_of_Work__c 
        FROM buildertek__Schedule_of_Value_Lines__c
        where  Id In:sovlineids
        ];

        integer i=1;
        
        list<buildertek__Schedule_of_Value_Lines__c> newsovlinesList = new list<buildertek__Schedule_of_Value_Lines__c>(); 

        if(sovlinesList.size() > 0){
            for(buildertek__Schedule_of_Value_Lines__c rec : sovlinesList){
                 buildertek__Schedule_of_Value_Lines__c newrec = new buildertek__Schedule_of_Value_Lines__c();
                 newrec.buildertek__Scheduled_Value__c = rec.buildertek__Scheduled_Value__c;
                 newrec.buildertek__Schedule_of_Values__c = recId;
               // newrec.buildertek__Schedule_of_Values__c.buildertek__Status__c = 'Company Approved';
                 newrec.buildertek__Item__c = rec.buildertek__Item__c;
                 newrec.buildertek__Description_of_Work__c = rec.buildertek__Description_of_Work__c;
                 newsovlinesList.add(newrec);
            }
        }  
        
        
        list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id IN:sovIds];
        
        if(updateStatus.size()>0){
            for(buildertek__Schedule_of_Values__c sovs : updateStatus){
                sovs.buildertek__Status__c = 'Company Approved';
            }
        }
        
        update updateStatus;
        
        
        
        system.debug(newsovlinesList.size());
        if(newsovlinesList.size()>0) {
            insert newsovlinesList;
        }
        return null;
        
    }
    
    
    
      @AuraEnabled
    public static String rejectSelectedSOVs(list<string> sovIds){
        system.debug(sovIds);
          list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id IN:sovIds];

        if(updateStatus.size()>0){
            for(buildertek__Schedule_of_Values__c sovs : updateStatus){
            sovs.buildertek__Status__c = 'Company Rejected';
        }
        }
        
        update updateStatus;
        system.debug('updates status ------> '+ updateStatus);
        return 'success';
    }
    


}