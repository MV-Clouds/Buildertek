trigger OpportunityTrgger on Opportunity (before update,before insert) {



//after insert Removed 2/5/2018
    Map<String,SalesSupportDirector__c> salesDirectors = SalesSupportDirector__c.getAll();
    List<String> AllSalesDirectors =new List<String>();
    for(String sd : salesDirectors.keyset())
    {
        AllSalesDirectors.add(salesDirectors.get(sd).User_Name__c);
    }
    List<User> SalesDireUsers = [select id,name from user where Name IN: AllSalesDirectors];
    Map<String,Id> DirName_Id = new Map<String,ID>();
    for(User u : SalesDireUsers )
    {
        DirName_Id.put(u.Name,u.Id);
    }
    
    for(Opportunity a : Trigger.new)
    {
        
       if((Trigger.isInsert && Trigger.isBefore) || (Trigger.isBefore && Trigger.isUpdate && Trigger.oldMap.get(a.id).Support_Region__c != a.Support_Region__c || String.IsBlank(a.Sales_Director__c) ))
      
       //a.UserProfile__c != 'System Administrator'&&
       //&&  a.UserProfile__c !='SalesOPS User'
        {
        
            if (a.Support_Region__c == 'Atlanta/Carolinas') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Brian Horton
            else if (a.Support_Region__c == 'Bay Area') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Randy Schmitz
            else if (a.Support_Region__c == 'Boston') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Peter Kujawski
            else if (a.Support_Region__c == 'Chicago') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Mike Lane
            else if (a.Support_Region__c == 'Dallas') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Jay Elms
            else if (a.Support_Region__c == 'Mountain') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);}
            else if (a.Support_Region__c == 'Florida') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Peter Kujawski
            else if (a.Support_Region__c == 'Hawaii') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Lance Murata
            else if (a.Support_Region__c == 'Houston') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Matt LeBlanc
            else if (a.Support_Region__c == 'International') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);}
            else if (a.Support_Region__c == 'Pacific Southwest') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);}
            else if (a.Support_Region__c == 'Memphis/Mid-South') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);}
            else if (a.Support_Region__c == 'New York') {a.Sales_Director__c =DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Brian Klansky
           // else if (a.Support_Region__c == 'Phoenix/Vegas') {a.Sales_Director__c =DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);}
            else if (a.Support_Region__c == 'Pacific Northwest') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Brad Baker
            else if (a.Support_Region__c == 'Toronto') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // John Carpenter
            else if (a.Support_Region__c == 'Vancouver') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Guthrie Cox
            else if (a.Support_Region__c == 'Washington DC') {a.Sales_Director__c = DirName_Id.get(salesDirectors.get(a.Support_Region__c).User_Name__c);} // Peter Kujawski
           
       }
    }
    
    // CSM Milestone
    
     Map<String,Customer_Success_Manager__c> CSM = Customer_Success_Manager__c.getAll();
     List<String> AllCSM =new List<String>();
     
     for(String sd:CSM.keySet())
     {
         AllCSM.add(CSM.get(sd).User_Name__c);
     }
    List<User> CSM1=[Select id,name from user where Name IN:AllCSM];
    Map<String,Id> MgrName_Id = new Map<String,ID>();
    for(User u: CSM1)
    {
        MgrName_Id.put(u.Name,u.Id);
    }
    for(Opportunity b : Trigger.new)
    {
    
    
         if((Trigger.isInsert && Trigger.isBefore) || (Trigger.isBefore && Trigger.isUpdate  && (Trigger.oldMap.get(b.id).Support_Region__c != b.Support_Region__c || String.ISBLANK(b.CSM_Project_Manager__c))))
         //&&  b.User_Name__c != 'Disha Mehtani'
         {
         
               if (b.Support_Region__c =='Atlanta/Carolinas'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Bay Area'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Boston'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Chicago'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Dallas'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Florida'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Hawaii'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Houston'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='International'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Pacific Southwest'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Memphis/Mid-South'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Mountain'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='New York'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Pacific Northwest'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Toronto'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Vancouver'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
             else if(b.Support_Region__c =='Washington DC'){b.CSM_Project_Manager__c = MgrName_Id.get(CSM.get(b.Support_Region__c).User_Name__c);}
         }
    }

    
    // Opportunity Sales Development Owner - Created by J
    
    Id profileId = Id.valueOf(UserInfo.getProfileId());
    Id currentUserId = Id.valueOf(UserInfo.getUserId());
    
    Profile userProfile = [SELECT Id, Name from Profile WHERE ID=:profileId LIMIT 1];


    if (trigger.isBefore && trigger.isInsert && userProfile.name == 'Sales Development')
    {
        for (Opportunity opty : Trigger.new)
        {
            opty.Inside_Sales_Owner__c = currentUserId;
        }
    }
    
// Trigger to populate target se as opportunity owner 04202017

 if(Trigger.isBefore && Trigger.isUpdate){
        Id opportunityRecordTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
        for(Opportunity oppRec : Trigger.new){
            if(oppRec.RecordTypeId != Trigger.oldMap.get(oppRec.Id).RecordTypeId &&  oppRec.RecordTypeId == opportunityRecordTypeId && oppRec.Target_SE__c != null) {
                    oppRec.OwnerId = oppRec.Target_SE__c;
            }
        }
    }
/*
//Create MileStone trigger

List<Milestone1_Milestone__c> mileStonesToInsert = new  List<Milestone1_Milestone__c>();
Map<String,Milestone_Config__c> mileStoneConfigMap = Milestone_Config__c.getAll();

if(!mileStoneConfigMap.isEmpty()){  
    
    for(Opportunity opp:Trigger.New){
        Boolean entryCriteria = opp.Install_Status__c == 'Active' && opp.Project_Manager__c != NULL && (opp.StageName == 'Closed: Won' || opp.StageName == 'Closed / Won');
        if(
            Trigger.isInsert && entryCriteria
            ||
            (
                Trigger.isUpdate && entryCriteria 
                &&
                ((Trigger.oldMap.get(opp.id).StageName != opp.StageName ) || (Trigger.oldMap.get(opp.id).Install_Status__c != opp.Install_Status__c) ||  

                (Trigger.oldMap.get(opp.id).Project_Manager__c !=opp.Project_Manager__c))
            )
        )
        {
            
            for(Milestone_Config__c mConfig:mileStoneConfigMap.values()){
                Milestone1_Milestone__c mileStone = new Milestone1_Milestone__c(
                    Name = mConfig.Name,
                    Opportunity__c = opp.Id,
                    Type__c = mConfig.Type__c,
                    OwnerId = opp.Project_Manager__c  
                );
                
                mileStonesToInsert.add(mileStone);
            }
        }   
    }
}
if(!mileStonesToInsert.isEmpty()){
    insert mileStonesToInsert;
}
*/

}