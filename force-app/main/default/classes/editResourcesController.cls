public class  editResourcesController{


    @AuraEnabled
    public static RfqDataTableWrapper getAccounts(Integer pageNumber, Integer pageSize,String selected,String searchaccount){
        try {            
            List<Account> accList = new List<Account>();
        
            Integer offset = (pageNumber - 1) * pageSize;
            //Total Records 
            Integer totalRecords = 0;
                        
            String accountsearch = '%'+''+'%';
            if(searchaccount != '' && searchaccount != null){
                accountsearch = '%'+searchaccount+'%';
            }

            if(searchaccount != ''){
                String query = 'Select COUNT() FROM Account WHERE id!=NULL';
                
                if(searchaccount != '' && searchaccount != null){
                    query = query+ ' AND Name LIKE \'%'+String.escapeSingleQuotes(searchaccount)+'%\'';
                }                                
                totalRecords = Database.countQuery(query);                
            }else{
                totalRecords = [SELECT COUNT() FROM Account ];
            }
    
            Integer recordEnd = pageSize * pageNumber;
            
            //Instance of Account DataTable Wrapper Class
            RfqDataTableWrapper objDT = new RfqDataTableWrapper();
            objDT.pageSize = pageSize;
            objDT.pageNumber = pageNumber;
            objDT.recordStart = offset + 1;
            objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            objDT.totalRecords = totalRecords;
            
            String queryList2 = '';
            String queryList = 'Select Id,Name FROM Account WHERE id!=NULL ';
            if(searchaccount != '' && searchaccount != null){
                queryList = queryList+ ' AND (Name LIKE \'%'+searchaccount+'%\')'; //String.escapeSingleQuotes(description)
            }                
            queryList2 = queryList+ ' ORDER BY Name';
            queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            
            List<Account> allContacts =  Database.query(queryList2);
            
            List<Account> accRecL = Database.query(queryList);
            
            List<RfqDataTableSubWrapper> subwrapperlist = new List<RfqDataTableSubWrapper>();
            for(Account a: accRecL){
                RfqDataTableSubWrapper rs = new RfqDataTableSubWrapper();
                rs.Id = a.Id;
                rs.Name = a.Name;
                rs.check = String.valueOf(a.Id) == selected ? true : false;
                subwrapperlist.add(rs);
            }
            objDT.accRecList = subwrapperlist;
                                                 
            return objDT;           

        } catch (Exception e) {
            return null;
        }
    }
    @AuraEnabled
    public static List<contactWrap> getContacts(String selected,String searchname,String searchaccount){
        String contactsearch = '%'+''+'%';
        if(searchname != '' && searchname != null){
            contactsearch = '%'+searchname+'%';
        }
        String accountsearch = '%'+''+'%';
        if(searchaccount != '' && searchaccount != null){
            accountsearch = '%'+searchaccount+'%';
        }
        String queryStr = 'Select Id,Name,AccountId,Account.Name From Contact Where Name LIKE:contactsearch ';
        if(searchaccount != '' && searchaccount != null){
            queryStr += ' AND Account.Name LIKE:accountsearch Order by Name';
        }else{
            queryStr += ' Order by Name';
        }
        List<Contact> conList = Database.query(queryStr);
        //List<Contact> conList = [Select Id,Name,AccountId,Account.Name From Contact Order by Name];
        List<contactWrap> conWrapList = new List<contactWrap>();
        String conName = '';
        if(conList.size() > 0){
            for(Contact con : conList){
                    contactWrap conwrapLabelVal = new contactWrap();
                    conwrapLabelVal.label = con.Name;
                    conwrapLabelVal.value = con.Id;
                    conwrapLabelVal.check = false;
                    conwrapLabelVal.accId = con.AccountId;
                    conwrapLabelVal.accName = '';
                    if(con.AccountId != null){
                        conwrapLabelVal.accName = con.Account.Name;
                    }
                    
                    if(selected == String.valueOf(con.Id) && selected != ''){
                     conwrapLabelVal.check = true;
                    }
                    conWrapList.add(conwrapLabelVal);
            }
        }
        return conWrapList;
    }


    @AuraEnabled
    public static RfqDataTableWrapper getContactsDup(String taskid, Integer pageNumber, Integer pageSize,String selected,String searchname,String searchaccount){
        List<Contact> ConList = new List<Contact>();
        
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;
        
        String contactsearch = '%'+''+'%';
        if(searchname != '' && searchname != null){
            contactsearch = '%'+searchname+'%';
        }
        String accountsearch = '%'+''+'%';
        if(searchaccount != '' && searchaccount != null){
            accountsearch = '%'+searchaccount+'%';
        }


        if(searchname != '' || searchaccount != ''){
            String query = 'Select COUNT() FROM Contact WHERE id!=NULL';
            if(searchname != '' && searchname != null){
                query = query+ ' AND Name LIKE \'%'+String.escapeSingleQuotes(searchname)+'%\'';
            }
            if(searchaccount != '' && searchaccount != null){
                query = query+ ' AND Account.Name LIKE \'%'+String.escapeSingleQuotes(searchaccount)+'%\'';
            }
            
            system.debug('111111111111111111111111'+query);
            totalRecords = Database.countQuery(query);
            system.debug('TotalRecords'+totalRecords);
        }else{
            totalRecords = [SELECT COUNT() FROM Contact ];
        }

        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        if(searchaccount != '' || searchname != ''){
            String queryList2 = '';
            buildertek__Project_Task__c tsk = [SELECT Id, buildertek__Contractor__c FROM buildertek__Project_Task__c WHERE Id = :taskid];
            System.debug('tsk---> '+tsk);
            System.debug('tsk account id ---> '+tsk.buildertek__Contractor__c);
            String queryList = 'Select Id,Name,AccountId,Account.Name FROM Contact WHERE id!=NULL ';
            if(searchname != '' && searchname != null){
                queryList = queryList+ ' AND (Name LIKE \'%'+searchname+'%\')'; //String.escapeSingleQuotes(description)
            }
            if(searchaccount != '' && searchaccount != null){
                queryList = queryList+ ' AND (Account.Name LIKE \'%'+searchaccount+'%\')';
            }
            queryList2 = queryList+ ' ORDER BY Name';
            queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            
            List<Contact> allContacts =  Database.query(queryList2);
            // system.debug(queryList);
            objDT.recordList = Database.query(queryList);
             system.debug(objDT.recordList);
        }
        else{
            System.debug('task id :--> '+taskid);
            buildertek__Project_Task__c tsk = [SELECT Id, buildertek__Contractor__c FROM buildertek__Project_Task__c WHERE Id = :taskid];
            System.debug('tsk---> '+tsk);
            System.debug('tsk account id ---> '+tsk.buildertek__Contractor__c);
            objDT.recordList = [Select Id,Name,AccountId,Account.Name
                                FROM Contact where AccountId = :tsk.buildertek__Contractor__c ORDER BY Name 
                                LIMIT :pageSize
                                OFFSET :offset];
        }

        List<contactWrap> conWrapList = new List<contactWrap>();
        if(objDT.recordList.size() > 0){
            for(Contact con : objDT.recordList){
                    contactWrap conwrapLabelVal = new contactWrap();
                    conwrapLabelVal.label = con.Name;
                    conwrapLabelVal.value = con.Id;
                    conwrapLabelVal.check = false;
                    conwrapLabelVal.accId = con.AccountId;
                    conwrapLabelVal.accName = '';
                    if(con.AccountId != null){
                        conwrapLabelVal.accName = con.Account.Name;
                    }
                    
                    if(selected == String.valueOf(con.Id) && selected != ''){
                     conwrapLabelVal.check = true;
                    }
                    conWrapList.add(conwrapLabelVal);
            }
        }
        objDT.wrapperList = conWrapList;
        
        return objDT;
        /* String queryStr = 'Select Id,Name,AccountId,Account.Name From Contact Where Name LIKE:contactsearch ';
        if(searchaccount != '' && searchaccount != null){
            queryStr += ' AND Account.Name LIKE:accountsearch Order by Name';
        }else{
            queryStr += ' Order by Name';
        }
        List<Contact> conList = Database.query(queryStr);
        //List<Contact> conList = [Select Id,Name,AccountId,Account.Name From Contact Order by Name];
        List<contactWrap> conWrapList = new List<contactWrap>();
        String conName = '';
        if(conList.size() > 0){
            for(Contact con : conList){
                    contactWrap conwrapLabelVal = new contactWrap();
                    conwrapLabelVal.label = con.Name;
                    conwrapLabelVal.value = con.Id;
                    conwrapLabelVal.check = false;
                    conwrapLabelVal.accId = con.AccountId;
                    conwrapLabelVal.accName = '';
                    if(con.AccountId != null){
                        conwrapLabelVal.accName = con.Account.Name;
                    }
                    
                    if(selected == String.valueOf(con.Id) && selected != ''){
                     conwrapLabelVal.check = true;
                    }
                    conWrapList.add(conwrapLabelVal);
            }
        } */
        //return conWrapList;
    }


    public class contactWrap{

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean check;
        @AuraEnabled
        public String accId;
        @AuraEnabled
        public String accName;
    }

    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        @AuraEnabled
        public List<Contact> recordList{ get; set; }

        @AuraEnabled
        public List<contactWrap> wrapperList ;

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean check;
        @AuraEnabled
        public String accId;
        @AuraEnabled
        public String accName;

        @AuraEnabled
        public List<RfqDataTableSubWrapper> accRecList {get;set;}
        // @AuraEnabled
        // public List<RfqDataTableSubWrapper> subwraplist {get;set;}

        // @AuraEnabled
        // public List<Account> accRecList{get;set;}        
    }

    public class RfqDataTableSubWrapper{
        @AuraEnabled
        public String Id {get;set;}

        @AuraEnabled
        public String Name {get;set;}
        
        @AuraEnabled
        public Boolean check {get;set;}
    }
}