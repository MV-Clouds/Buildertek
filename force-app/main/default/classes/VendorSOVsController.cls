public class VendorSOVsController {
    
    
    @AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
    }
    
    
    @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSovType(String recordId){
        
        buildertek__Schedule_of_Values__c SOVType = [select Id, Name,buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c from buildertek__Schedule_of_Values__c WHERE Id =: recordId];
        
        return SOVType;
    }
    
    
    @AuraEnabled
    public static  List<SOVWrapper>  getSOVs(String recordId){       
        
        buildertek__Schedule_of_Values__c mainRecord = [select Id, buildertek__Project__c from buildertek__Schedule_of_Values__c where Id =: recordId];
        
           String projectId = mainRecord.buildertek__Project__c;
            
        List<SOVWrapper> SOVWrapperList = new List<SOVWrapper>();        
       
        list<buildertek__Schedule_of_Values__c> sovsList = [ SELECT Id,
                                                            Name, buildertek__Project__c, 
                                                            buildertek__Project__r.Name,
                                                            buildertek__Type__c,RecordTypeId, recordtype.name,
                                                            buildertek__Date_Submitted__c, 
                                                            buildertek__Vendor__c,
                                                            buildertek__Status__c ,(SELECT Id, Name, 
                                                                                    buildertek__Scheduled_Value__c, buildertek__Schedule_of_Values__c,
                                                                                    buildertek__Schedule_of_Values__r.Name, 
                                                                                    buildertek__Item__c, buildertek__Description_of_Work__c ,
                                                                                    buildertek__Vendor__c, buildertek__Vendor__r.Name
                                                                                    FROM buildertek__Schedule_of_Values_Lines__r where  buildertek__Status__c='Approved')
                                                            FROM buildertek__Schedule_of_Values__c  
                                                            where  buildertek__Status__c='Company Approved'  AND buildertek__Project__c =: projectId AND recordtype.name = 'Vendor'
                                                           ];
        integer i=1;
        // integer j=1;
        
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
                obj.vendorName = rec.buildertek__Vendor__c;
                obj.expanded = false; 
                integer j=1;
                
                List<SOVLinesWrapper> SOVLinesList = new List<SOVLinesWrapper>(); 
                String vName = '';
                for(buildertek__Schedule_of_Value_Lines__c lines : rec.buildertek__Schedule_of_Values_Lines__r){
                    SOVLinesWrapper sovLi = new SOVLinesWrapper();
                    sovLi.RowNumber = j;
                    sovLi.RecordId = lines.Id;
                    sovLi.Name = lines.Name;
                    sovLi.ScheduleOfValues = rec.Id;
                    sovLi.Item = lines.buildertek__Item__c;
                    sovLi.Description = lines.buildertek__Description_of_Work__c ;
                    sovLi.ScheduleValue = lines.buildertek__Scheduled_Value__c;
                    sovLi.expanded = false;
                    if(lines.buildertek__Vendor__c != null){
                        vName = lines.buildertek__Vendor__r.Name; 
                      sovLi.vendorName = lines.buildertek__Vendor__r.Name;  
                    }
                    
                    SOVLinesList .add(sovLi);
                    
                    j=j+1;
                }
                obj.vendorName = vName;
                obj.sovlinesList= SOVLinesList;
                SOVWrapperList.add(obj);  
                
                i++;
            }
        } 
        system.debug(SOVWrapperList.size());
        
        system.debug('SOVWrapperList'+SOVWrapperList);
        
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
        @AuraEnabled public boolean expanded;
        @AuraEnabled public String vendorName;
        
        @AuraEnabled public list<SOVLinesWrapper> sovlinesList;
        
        
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
                obj.expanded = false;                
                SOVLinesWrapperList.add(obj);          
                i++;
            }
        }   
        system.debug(SOVLinesWrapperList.size());
        system.debug('SOVLinesWrapperList'+SOVLinesWrapperList);
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
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public String vendorName;
    } 
    
    
    
    @AuraEnabled
    public static string ApproveSOV(string recId, list<string> sovIds){       
        
        
        
        list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id IN:sovIds];
        
        if(updateStatus.size()>0){
            for(buildertek__Schedule_of_Values__c sovs : updateStatus){
                sovs.buildertek__Status__c = 'Company Approved';
            }
        }
        
        update updateStatus;
        
        return null;
        
    }
    
    
    @AuraEnabled
    public static string rejectSOVs(string recId, list<string> sovIds){       
        
        
        
        list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c,buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c where Id IN:sovIds];
        
        if(updateStatus.size()>0){
            for(buildertek__Schedule_of_Values__c sovs : updateStatus){
                sovs.buildertek__Status__c = 'Company Rejected';
            }
        }
        
        update updateStatus;
        
        system.debug('updateStatus'+updateStatus);
        
        return null;
        
    }
    
    
    
    @AuraEnabled
    public static string createMasterSOV1 (string recId,list<Id> sovlineids, list<string> sovIds){       
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
    public static Integer createSOVLines(List<String> selectedSOV, String newSOV){  
        
        
        list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: newSOV ORDER BY buildertek__Item__c DESC ];
            
            integer itemInc = 100;
            
            if(lastSOV.size() > 0){
               itemInc = Integer.valueOf(lastSOV[0].buildertek__Item__c)+1;
            }
            
        
        Integer itemno=1;
        System.debug('List of SOV Ids-----------------------------------   '+selectedSOV);
         System.debug('New SOV Id-----------------------------------   '+newSOV);
        Set<Id> sovIDs=new Set<Id>();
         list<buildertek__Schedule_of_Values__c> updateStatus = [select Id, Name, buildertek__Status__c,
                                                                 buildertek__Date_Submitted__c from buildertek__Schedule_of_Values__c 
                                                                 where Id IN:selectedSOV];
        if(updateStatus.size()>0){
        for(buildertek__Schedule_of_Values__c SOV:updateStatus){
            sovIDs.add(SOV.Id);
        }
        }
        
        system.debug('sovIDs----->'+sovIDs);
        
         list<buildertek__Schedule_of_Value_Lines__c> sovlinesList = [ SELECT Id, 
                                                                      Name, buildertek__Scheduled_Value__c,
                                                                      buildertek__Schedule_of_Values__c,
                                                                      buildertek__Schedule_of_Values__r.Name,
                                                                      buildertek__Status__c,
                                                                      buildertek__Vendor__c,
                                                                      buildertek__Vendor_SOV_Line__c,
                                                                      buildertek__Schedule_of_Values__r.buildertek__Status__c,
                                                                      buildertek__Item__c, buildertek__Description_of_Work__c,
                                                                      buildertek__Item_New__c
                                                                      FROM buildertek__Schedule_of_Value_Lines__c where   buildertek__Schedule_of_Values__c In:sovIDs AND buildertek__Status__c = 'Approved'];
        
         list<buildertek__Schedule_of_Value_Lines__c> newsovlinesList = new list<buildertek__Schedule_of_Value_Lines__c>(); 
        system.debug('sovlinesList.size() --->' +sovlinesList.size());
        
        if(sovlinesList.size()>0){
            for(buildertek__Schedule_of_Value_Lines__c SOVLines : sovlinesList){
                buildertek__Schedule_of_Value_Lines__c newsovline = new buildertek__Schedule_of_Value_Lines__c(); 
                newsovline.buildertek__Schedule_of_Values__c=newSOV;
                
                
                
                newsovline.buildertek__Item__c=String.valueOf(itemInc);
                newsovline.buildertek__Vendor__c=SOVLines.buildertek__Vendor__c;
                newsovline.buildertek__Scheduled_Value__c = SOVLines.buildertek__Scheduled_Value__c;
                newsovline.buildertek__Description_of_Work__c=SOVLines.buildertek__Description_of_Work__c;
                newsovline.buildertek__Status__c='Approved';
                newsovline.buildertek__Vendor_SOV_Line__c = SOVLines.Id;
                newsovlinesList.add(newsovline);
                itemno++;
                itemInc++;
            }
        }
        
        system.debug('newsovlinesList--->'+newsovlinesList.size());
        
        if(newsovlinesList.size()>0){
            insert newsovlinesList;
        }
         return sovlinesList.size();
    }
    
}