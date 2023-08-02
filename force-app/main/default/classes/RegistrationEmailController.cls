global class RegistrationEmailController { 
    global string RecId {get;set;}
    global string objectType {get; set;}
     global buildertek__Session_Participant__c SesRec{
     get{
         SesRec = [Select Id, name,buildertek__Participant_Name__r.Name,
                   buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__r.Name,
                   buildertek__Course_Session_Scheduling__r.buildertek__Session_Date__c,
                   buildertek__Course_Session_Scheduling__r.buildertek__Session_Time_NEW__c,
                   buildertek__Course_Session_Scheduling__r.buildertek__Session_Duration__c,
                   buildertek__Course_Session_Scheduling__r.buildertek__Session_Facilitator__r.Name
                   From buildertek__Session_Participant__c where id =: RecId ];
         return SesRec;
      }
      set;
     }
     global buildertek__MSA_Settings__c MsaUrl{
     get{
         MsaUrl = [Select id,name,buildertek__Company_Full_Name__c, buildertek__Site_URL__c from buildertek__MSA_Settings__c ];
         return MsaUrl;
        }
        set;
     }
     global buildertek__Training_Settings__c SiteUrl{
     get{
         SiteUrl = [SELECT Id, Name, buildertek__Site_URL__c FROM buildertek__Training_Settings__c ];
         return SiteUrl;
        }
        set;
     }

}