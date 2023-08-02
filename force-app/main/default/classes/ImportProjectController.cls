public class ImportProjectController {
    @AuraEnabled
    public static string insertData(String strfromle){
        String returnresponse ='';
        List<buildertek__Project__c> ProjectListtoInsert = new List<buildertek__Project__c>();
        
        List<Account> AccountListtoInsert = new List<Account>();
        
        //system.debug('strfromle = ' + strfromle);
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
        system.debug('datalist = ' + datalist);
        system.debug('datalistSize = ' + datalist.size());
        
        //  List<Account> account = [select id, Name from account ];
        
        list<String> accNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.Account != null && wrapper.Account != ''){
                accNames.add(wrapper.Account);
            }
            
        }
        list<Account> acc1 = new list<Account>();
        
        acc1 = [select Id, Name from Account where Name IN: accNames];
        
        map<String, Account> accmap = new map<String,Account>();
        
        for(Account accItem : acc1){
            accmap.put(accItem.Name,accItem); 
        }
        
        system.debug(accmap.keySet());
        
        
        
         list<String> userNames = new List<String>();
        
        for(fieldWrapper wrapper: datalist){
            if(wrapper.ProjectManager != null && wrapper.ProjectManager != ''){
                userNames.add(wrapper.ProjectManager);
            }
            
        }
        list<User> user1 = new list<User>();
        
        user1 = [select Id, Name from User where Name IN: userNames];
        
        map<String, User> usermap = new map<String,User>();
        
       for(User userItem : user1){
            usermap.put(userItem.Name,userItem); 
        }
        

 system.debug(usermap.keySet());        
        
        
        Map<String,Account> newAccountMap = new Map<String,Account>();
        for(fieldWrapper Accountwrapper: datalist){
            system.debug(accmap.keySet().contains(Accountwrapper.Account));
            if(accmap.keySet().contains(Accountwrapper.Account) == false){
                if(Accountwrapper.Account != null && Accountwrapper.Account != ''){
                    system.debug(Accountwrapper.Account);
                    Account acc =new  Account();
                    acc.Name = Accountwrapper.Account;
                    acc.BillingCity  = Accountwrapper.City;
                    acc.BillingState = Accountwrapper.State;
                    acc.BillingPostalCode = Accountwrapper.Zip;
                    acc.Phone = Accountwrapper.AccountPhone;
                    acc.buildertek__Email_Address__c = Accountwrapper.AccountEmail;
                    AccountListtoInsert.add(acc);
                } 
                
            }
        }
        system.debug(AccountListtoInsert.Size());
        if(AccountListtoInsert.Size() > 0){
            try {
                system.debug(AccountListtoInsert);
                insert AccountListtoInsert;
                system.debug(AccountListtoInsert[0].Id);
                for(Account acc: AccountListtoInsert){
                    system.debug(acc.Name+','+acc);
                    newAccountMap.put(acc.Name, acc);
                }
                
                for(Account accItem : acc1){
                    newAccountMap.put(accItem.Name,accItem); 
                }
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                returnresponse = 'ERROR';
            }
        }
        
        
        
        for(fieldWrapper wrapper: datalist){
            buildertek__Project__c pro =new  buildertek__Project__c();
            pro.Name = wrapper.ProjectName;
            pro.buildertek__Contract_Amount__c = wrapper.ContractAmount;
            pro.buildertek__Address__c = wrapper.Address;
            pro.buildertek__City__c = wrapper.City;
            pro.buildertek__State__c = wrapper.State;
            pro.buildertek__Zip__c = wrapper.Zip;
            pro.buildertek__Stage__c = wrapper.Stage;
                if(usermap.keySet().contains(wrapper.ProjectManager) && wrapper.ProjectManager != null && wrapper.ProjectManager != ''){
                pro.buildertek__Project_Manager__c = usermap.get(wrapper.ProjectManager).Id;
                }
            
            
            if(newAccountMap.keySet().contains(wrapper.Account) && wrapper.Account != null && wrapper.Account != ''){
                system.debug(pro.buildertek__Account__c);
                pro.buildertek__Customer__c = newAccountMap.get(wrapper.Account).Id;
                system.debug(pro.buildertek__Account__c);
            }
            system.debug(pro);
            ProjectListtoInsert.add(pro);            
        }
        
        if(ProjectListtoInsert.Size() > 0){
            try {
                system.debug(ProjectListtoInsert);
                insert ProjectListtoInsert;
                system.debug(ProjectListtoInsert);
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                system.debug(ex);
                returnresponse = 'ERROR'+' '+ex.getMessage()+' '+ex.getLineNumber();
                //returnresponse = 'ERROR';
            }
        }
        return returnresponse;
    }
    
    public class fieldWrapper{        
        public String ProjectName;        
        public Decimal ContractAmount;        
        public String Address;
        public String City;
        public String State;
        public String Zip;
        public String ProjectManager;
        public String Stage;
        
        public String Account;
        public String AccountAddress;
        public String AccountCity;
        public String AccountState;
        public String AccountPhone;
        public String AccountEmail;
        
    } 
    
    /* for export data into csv file  */
    @AuraEnabled
    public static list <buildertek__Project__c> fetchContact(){      
        List <buildertek__Project__c> returnConList = new List < buildertek__Project__c > ();        
        for(buildertek__Project__c con: [SELECT Name, buildertek__Contract_Amount__c, buildertek__Address__c, buildertek__City__c, buildertek__State__c, buildertek__Zip__c From buildertek__Project__c LIMIT 5 ]) {
            returnConList.add(con);
        }
        return returnConList;
    }
}