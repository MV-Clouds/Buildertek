/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  21-Sep-2017
*/
public with sharing class BT_FilterCriteriaCompoController {
    
    
    
    /**************************************************************************
     **************************************************************************
            LIGHTNING FILTER COMPONET 
     **************************************************************************
    ****************************************************************************/ 
    
    public class OptionList{
        public OptionList(String label, String value, String type){
            this.label = label;
            this.value = value;
            this.type = type;
            this.selected = false;
        }
        @AuraEnabled
        public Boolean selected{set; get;}
        @AuraEnabled
        public String type {private set;get;}
        @AuraEnabled
        public String label {private set;get;}
        @AuraEnabled
        public String value {private set;get;}
    }
    
        
    @AuraEnabled
    public static OptionList[] getFieldOptions(String sobjectName){
        
        List<Schema.DescribeFieldResult> fieldList = DescribeHandler.getFieldApiNames(sobjectName);
        List<OptionList> options = new List<OptionList>();
        for(Schema.DescribeFieldResult fieldResult : fieldList){
            options.add(new OptionList( fieldResult.getLabel(), fieldResult.getName(), fieldResult.getType().name()));
        }
        return options;
    }
}