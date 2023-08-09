public with sharing class BT_PrintLineItemController {
    public String recordId { get; set; }
    public String childFieldApi  { get; set; }
    public list<string> Fieldslist  { get; set; }
    public list<string> newChildApiList  { get; set; }
    public List<sObject> childObjRecords { get; set; }
    public List<AggregateResult> childObjGroup { get; set; }
    public string childObjName  { get; set; }
    public string parentObjName  { get; set; }
    public map<string,string> mapForLabel  { get; set; }
    public map<string,boolean> mapForTypeBoolean  { get; set; }
    public map<string,string> mapForFieldType  { get; set; }
    public List<string> numberOfChildFields  { get; set; }
    public decimal totalNumberOfChildFields { get; set; }
    public decimal widthOfLineItemTable { get; set; }
    public decimal widthOfLastHeaderValue { get; set; }
    public list<sObject> childObjGroups { get; set; }
    public String GroupBy  { get; set; }
    public String groupObject  { get; set; } 
    Public String GroupObjecName  { get; set; }
    public String groupObjects{  get;set;}
    public Map<String,string> MappingValues {get; set;}
    public boolean ShowValues { get; set; }
    public string currencySymbol { get; set; }
    public String totalSumOfFields { get; set; }
    public List<wrapperClass> wrapperClassList { get; set; }
     /*
     * @Created Date:- 17th September 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getChildRecordsList
     * @ReturnType : List<String>
     * @param : none
     * @Description : Get all the Child Records based on Parent Object
     * @LAST MODIFIED DATE: 18th September 2018
     */ 
    public list<String> getChildRecordsList(){
        ShowValues = false;
        childObjGroup = new list<AggregateResult>();
        numberOfChildFields = childFieldApi.split(',');
        system.debug('numberOfChildFields '+numberOfChildFields.size());
        totalNumberOfChildFields = numberOfChildFields.size();
        widthOfLineItemTable = (100 / totalNumberOfChildFields)-0.23;

        widthOfLastHeaderValue = widthOfLineItemTable + 2.63;
        system.debug('widthOfLineItemTable @@@@@@@ '+widthOfLineItemTable);
        Fieldslist = new list<string>();    
        mapForLabel = new map<string,string>();
        mapForFieldType = new map<string,string>();
        mapForTypeBoolean = new map<string,boolean>();
        recordId =ApexPages.currentPage().getParameters().get('id');
        system.debug('Field @@@@@@@@ '+childFieldApi);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType ctype = gd.get(childObjName);
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap(); 
        system.debug('FieldsName '+fmap.keySet());
        for(String fieldName: fmap.keySet()) { 
            mapForLabel.put(fieldName,fmap.get(fieldName).getDescribe().getLabel()); 
            mapForFieldType.put(fieldName,string.valueof(fmap.get(fieldName).getDescribe().getType())); 
        }
        system.debug('mapForLabel->'+mapForLabel);
        system.debug('mapForFieldType->'+mapForFieldType);
        system.debug('childFieldApi->'+childFieldApi);
        
        childFieldApi = childFieldApi.replace('\r\n', ' ');
        childFieldApi = childFieldApi.replace('\n','');
        childFieldApi = childFieldApi.trim();
        for(string s : childFieldApi.split('\\,')){
            if(s != ''){
            Fieldslist.add(s);
            }
        } 
        system.debug('Fieldslist->'+Fieldslist);
        newChildApiList = new list<string>();
        for(string s : Fieldslist){
            system.debug('/222'+mapForFieldType);
            system.debug('/222'+s);
            system.debug('/222# ---> '+mapForFieldType.get(s));
            if(string.valueOf(mapForFieldType.get(s.toLowercase())) == 'REFERENCE'){
                system.debug('Reference Fields '+newChildApiList);
                newChildApiList.add((s.replace('__c', '__r.Name')).toLowercase());
                mapForLabel.put((s.replace('__c', '__r.Name')).toLowercase(),mapForLabel.get(s.toLowercase()));
            }
            else{
                system.debug('Non Reference Fields '+newChildApiList);
                newChildApiList.add((s.replace(' ','')).toLowercase());
            }
            
        }
        string newchildFieldApi= ',';
        for(string s : newChildApiList){
            newchildFieldApi += (s.toLowercase()).replace(' ','');
            newchildFieldApi +=',';
        }
        newchildFieldApi =newchildFieldApi.removeEnd(',');
        system.debug('myquery->'+newchildFieldApi);
        string myquery = '';
        string myqueries = '';
        List<AggregateResult> agrQueries = new List<AggregateResult>();
        if(groupObject != '' && groupObject != null){
            myquery = 'select id, '+ groupObject + newchildFieldApi +' from '+ childObjName +' where '+ parentObjName +'=: recordId';
        }
        else{
            myquery = 'select id' + newchildFieldApi +' from '+ childObjName +' where '+ parentObjName +'=: recordId'; 
        }
        if(GroupBy == 'true'){
            String aggregateFields = '';
            integer i=1;
            for(string sumOfFields : totalSumOfFields.split('\\,')){
                aggregateFields += ', SUM('+sumOfFields.trim()+') total'+i;
                i++;
            }
            //myqueries = 'select '+groupObject+' from '+childObjName+ ' where '+ parentObjName+'=\''+String.escapeSingleQuotes(recordId)+'\' Group By '+ groupObject;
            myqueries = 'select '+ groupObject + aggregateFields + ' from '+childObjName+ ' where '+ parentObjName +'=: recordId Group By '+ groupObject;
            system.debug('myqueries Results '+myqueries);
            childObjGroup = database.query(String.escapeSingleQuotes(myqueries));
            system.debug('childObjGroup Results '+childObjGroup);
            ShowValues = false;
            MappingValues = new Map<String, string>();
            System.debug('**************************** '+mapForFieldType.get(groupObject.toLowercase()));
            Map<string, string> GroupNameMap = new Map<String, string>();
            if(string.valueOf(mapForFieldType.get(groupObject.toLowercase())) == 'REFERENCE'){
                list<string> NewList = new list<string>();
                for(sObject Obj :childObjGroup){
                    System.debug('****************************Names '+Obj.get(groupObject));   
                    NewList.add(String.valueof(Obj.get(groupObject))); 
                }
                string Childs = 'select Id, Name from '+groupObjects+' where id IN: NewList';
                childObjGroups = database.query(String.escapeSingleQuotes(Childs));
                
                for(sObject  Grps : childObjGroups){
                    GroupNameMap.put((String)Grps.get('Id'),(String)Grps.get('Name'));
                }
                system.debug('************************Allvalues '+childObjGroups);
                ShowValues = true; 
                system.debug('childObjGroup  Size -->  '+childObjGroup.size());
                Map<String, Boolean> fieldTypeMap = new Map<String, Boolean>();
                for(string sumOfFields : totalSumOfFields.split('\\,')){
                    fieldTypeMap.put(sumOfFields.trim(), true);
                }
                wrapperClassList = new List<wrapperClass>();
                
                for(AggregateResult  objAgr: childObjGroup){
                    integer j=1;
                    integer child = 1;
                    for(string sumOfFields : childFieldApi.split('\\,')){
                        if(child >=2){ 
                            if(fieldTypeMap.get(sumOfFields.trim()) == true){
                                wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get(groupObject)), (Decimal)objAgr.get('total'+j), string.valueOf(mapForFieldType.get(sumOfFields.toLowercase().replace(' ',''))))); 
                                j++;
                            }else{
                                wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get(groupObject)), null, 'false'));
                            }
                            
                        }
                        child++;
                    }
                }
                system.debug('wrapperClassList @@@@@@ '+wrapperClassList);
            }
            else{
                
                for(AggregateResult  objAgr: childObjGroup){
                }
            }
            
            
            
            
        }
        system.debug('myquery->'+myquery);
        childObjRecords = database.query(String.escapeSingleQuotes(myquery));
        
        
        system.debug('childObjRecords->'+childObjRecords);
        system.debug('mapForLabel @@@@@@ '+mapForLabel);
        system.debug('newChildApiList  &&&&&&& '+newChildApiList);
        system.debug('childObjGroups  &&&&&&& '+childObjGroups);
        return newChildApiList;
        
    }
    
    public class wrapperClass {
        public String groupName { get; set; }
        public Decimal totalValue { get; set; }
        public String fieldType { get; set; }
        
        public wrapperClass(String groupName, Decimal totalValue, String fieldType){
            this.groupName = groupName;
            this.totalValue = totalValue;
            this.fieldType = fieldType;
        }
    }

}