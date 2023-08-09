trigger DatesTrigger on User (Before insert,Before update, After update, After Insert) {
    
        if(Trigger.isBefore && Trigger.isUpdate){
        for(User u: trigger.new)
            {
                if(u.IsActive != trigger.oldMap.get(u.Id).IsActive)  
                {
                    if (u.IsActive == False)
                    {
                        u.Deactivated_Date_Time__c = Datetime.now(); 
                    }
                    else if (u.IsActive == True)
                    {
                        u.Activated_Date_Time__c =Datetime.now();
                    }
                    
                }
                
                 if(u.ProfileId != trigger.oldMap.get(u.Id).ProfileId)  
                {                     
                        u.Profile_Change_Date_Time__c = Datetime.now(); 
                   
                }
            }
      }
    
        /*if (trigger.isBefore && trigger.isInsert)
       {
         
            for(User usr: trigger.new)
            {
                usr.Created_Date_Time__c = Datetime.now();
            }
        } */
}