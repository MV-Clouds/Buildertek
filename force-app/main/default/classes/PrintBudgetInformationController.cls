public with sharing class PrintBudgetInformationController {
    public buildertek__Budget__c budget {get; set; }    
    public String budgetId { get; set; }
    public String SectionName { get; set; } 
    public List<buildertek__Budget_Item__c> budgetLineslist{ get; set; }
    
    public PrintBudgetInformationController(){
        budgetId = Apexpages.currentPage().getParameters().get('Id');
        system.debug('budgetId '+budgetId); 
         if(Schema.sObjectType.buildertek__Budget__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Original_Budget__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Type__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Pending_CO__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Approved_CO__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Total_CO__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Committed_Costs__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Direct_Costs__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Pending_Cost_Changes__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Projected_Costs__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
           budget = [select Id, Name, buildertek__Project__c, buildertek__Project__r.Name, 
                    buildertek__Original_Budget__c, buildertek__Type__c, buildertek__Pending_CO__c,
                    buildertek__Approved_CO__c, buildertek__Total_CO__c, buildertek__Committed_Costs__c,
                    buildertek__Direct_Costs__c, buildertek__Pending_Cost_Changes__c, buildertek__Projected_Costs__c
                    from buildertek__Budget__c where Id =: budgetId];
        	}
                    
         if(Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible()&&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product_Name__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Original_Budget__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Modification__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Revised_Budget__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Projected_Costs__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Total_Costs__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Pending_CO__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Approved_CO__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Total_CO__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Profit_Loss__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isAccessible() &&
        	Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.buildertek__Sort_Id__c.isAccessible()){           
            budgetLineslist = [select Id, buildertek__Product__c, buildertek__Product_Name__c, buildertek__Quantity__c,
                        buildertek__Unit_Price__c, buildertek__Original_Budget__c, buildertek__Budget_Modification__c,
                        buildertek__Revised_Budget__c, buildertek__Projected_Costs__c, buildertek__Total_Costs__c,
                        buildertek__Pending_CO__c, buildertek__Approved_CO__c, buildertek__Total_CO__c,
                        buildertek__Profit_Loss__c from buildertek__Budget_Item__c where buildertek__Budget__c =: budgetId ORDER By buildertek__Budget_Line_Group__r.buildertek__Sort_Id__c ASC];
        	}
                        
                        
                    
    }
    /* code for Displaying Data Dynamically */
    public String viewFieldApi {get;set;}
    public list<string> Fieldslist {get;set;}
    public list<string> newApiList {get;set;}
    public sObject parentobjRecord{get;set;}
    public string objectName {get;set;}
    public map<string,string> mapForLabel {get;set;}
    public map<string,Schema.DisplayType> mapForFieldType {get;set;}
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
                newApiList.add(s.toLowercase());
            }
        }
        string newViewFieldApi= ',';
        for(string s : newApiList){
            newViewFieldApi += s;
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