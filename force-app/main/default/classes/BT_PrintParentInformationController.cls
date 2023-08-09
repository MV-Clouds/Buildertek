public with sharing class BT_PrintParentInformationController {
    public String budgetId { get; set; }
    public String SectionName { get; set; } 
    public String viewFieldApi {get;set;}
    public list<string> Fieldslist {get;set;}
    public list<string> newApiList {get;set;}
    public sObject parentobjRecord{get;set;}
    public string objectName {get;set;}
    public map<string,string> mapForLabel {get;set;}
    public map<string,Schema.DisplayType> mapForFieldType {get;set;}
    
    /*
     * @Created Date:- 17th September 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getApiList
     * @ReturnType : List<String>
     * @param : none
     * @Description : Get all the Records of Selected Object
     */
     
    public list<String> getApiList(){
        Fieldslist = new list<string>();    
        mapForLabel = new map<string,string>();
        mapForFieldType = new map<string,Schema.DisplayType>();
        budgetId =ApexPages.currentPage().getParameters().get('id');
        system.debug('Field @@@@@@@@ '+viewFieldApi);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType ctype = gd.get(objectName);
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap(); 
        system.debug('FieldsName '+fmap.keySet());
        for(String fieldName: fmap.keySet()) { 
            mapForLabel.put(string.valueof(fieldName.toLowercase()),fmap.get(fieldName).getDescribe().getLabel()); 
            mapForFieldType.put(string.valueof(fieldName.toLowercase()),fmap.get(fieldName).getDescribe().getType()); 
         }
        system.debug('mapForLabel->'+mapForLabel); 
        system.debug('mapForFieldType->'+mapForFieldType);
        system.debug('viewFieldApi->'+viewFieldApi);
        viewFieldApi = viewFieldApi.replace('\r\n', ' ');
        viewFieldApi = viewFieldApi.replace('\n','');
        viewFieldApi = viewFieldApi.trim();
        for(string s : viewFieldApi.split('\\,')){
            if(s != ''){
            Fieldslist.add(s);
            }
        } 
        system.debug('Fieldslist->'+Fieldslist);
        newApiList = new list<string>();
        for(string s : Fieldslist){
            system.debug('/222'+mapForFieldType.keySet());
            system.debug('/222'+s);
            system.debug(mapForFieldType.get(s.toLowercase()) + ' /22222 ' + mapForFieldType.get('buildertek__is_budget_locked__c'));
            if(string.valueOf(mapForFieldType.get(s.toLowercase())) == 'REFERENCE'){
                system.debug('Reference Fields '+newApiList);
                newApiList.add((s.replace('__c', '__r.Name')).toLowercase());
               //newApiList.add(s);
                mapForLabel.put((s.replace('__c', '__r.Name')).toLowercase(),mapForLabel.get(s.toLowercase())); 
            }
            else{
                system.debug('Non Reference Fields '+newApiList);
                newApiList.add((s.toLowercase()).replace(' ',''));
            }
        }
        string newViewFieldApi= ',';
        for(string s : newApiList){
            newViewFieldApi += s.replace(' ','');
            newViewFieldApi +=',';
        }
        newViewFieldApi =newViewFieldApi.removeEnd(',');
        system.debug('myquery->'+newViewFieldApi);
        string myquery = 'select id'+newViewFieldApi+' from '+objectName+' where id=: budgetId';
        system.debug('myquery->'+myquery);
        parentobjRecord = database.query(String.escapeSingleQuotes(myquery));
        system.debug('parentobjRecord->'+parentobjRecord);
        system.debug('mapForLabel @@@@@@ '+mapForLabel);
        system.debug('newApiList  &&&&&&& '+newApiList);
        return newApiList;
        
    }
}