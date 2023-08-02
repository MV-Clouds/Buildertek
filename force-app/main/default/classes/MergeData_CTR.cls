public with sharing class MergeData_CTR {
    //public String mergeFieldData = 'Account name is {!Account__r.Name} and FAX is {!Fax} and Phone is {!Phone}';
    
    public string QuoteTemplateId{get;set;}
    public String QuoteID{get;set;}
    public String SObjectName{get;set;}
    
    public String m_MergeData(String mergeFieldData){
        Set<String> fieldNames = new Set<String>(); 
        Map<String, String> fieldMapping = new Map<String, String>();
        mergeFieldData = mergeFieldData.replace('{!',' {!');
        mergeFieldData = mergeFieldData.replace('}',' }');
        
        
        for(String s : mergeFieldData.split(' ')){
             
            if(s.StartsWith('{!')){ 
                
                string st = s.subString(2,s.length()-0);
                st = st.replace('<strong>','');
                st = st.replace('</strong>','');
                fieldNames.add(st);
            }
        }
        
        if(fieldNames.size() > 0){
        
        String sObjectQuery = 'SELECT Id';
        Integer i=0;
        
        for(String s : fieldNames){
            if(i == fieldNames.size())
                sObjectQuery = sObjectQuery + s + ' ';
            else
                sObjectQuery = sObjectQuery + ', '+ s;
                
            i++;
        }
        system.debug('QuoteID --------> '+QuoteID);
        sObjectQuery = sObjectQuery + ' FROM '+SObjectName+' where id =: QuoteID LIMIT 1';
        system.debug('sObjectQuery ----------> '+sObjectQuery);
        sObject querySOject = DataBase.query(String.escapeSingleQuotes(sObjectQuery));
    System.debug('------querySOject--------'+querySOject);
    //System.debug('--------------'+fieldNames);
        for(String s : fieldNames){
        	if(!s.contains('.')){
            	if(querySOject.get(s) != null){
            	    
                    if(s.trim() == 'Date__c'){
                    Date DateValue = Date.valueof(querySOject.get('Date__c'));
                    
                    Datetime D = Datetime.newInstance(DateValue.year(),DateValue.Month(),DateValue.day());
                    String dateOutput = D.format('MM/dd/yyyy');
                    mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', dateOutput );   
                    }
                     
                    mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', String.valueOf(querySOject.get(s)));
                    }
                    else{
                    if(s.trim() == 'Date__c'){
                    Date DateValue = date.today();
                    
                    Datetime D = Datetime.newInstance(DateValue.year(),DateValue.Month(),DateValue.day());
                    String dateOutput = D.format('MM/dd/yyyy');
                    mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', dateOutput );   
                    }					
                    mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', ''); 
                  }
            }else{
                List<String> splitList = s.split('\\.');
                string ReleationField = splitList[0].replace('__r','__c');
                
                
                
                if(splitList.size()>0 && querySOject.get(ReleationField) != null){
                    if(String.valueOf(querySOject.getSobject(s.split('\\.')[0]).get(s.split('\\.')[1])) == null || String.valueOf(querySOject.getSobject(s.split('\\.')[0]).get(s.split('\\.')[1])) == ''){
                        mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', ' ');
                    }
                    else{
                        mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', String.valueOf(querySOject.getSobject(s.split('\\.')[0]).get(s.split('\\.')[1]))); 
                    }
                }else{
                	mergeFieldData = mergeFieldData.replace('{!'+s.trim()+' }', ' ');
                	
                }
            }
        }
        return mergeFieldData;
        }
        else{
        return mergeFieldData;  
        }
    }
}