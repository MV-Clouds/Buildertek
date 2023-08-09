/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  21-Sep-2017
*/
public with sharing class GridOptions {
    public class ColumnModel{
        public String name {get; set;}
        public String index {get; set;}
        public String sorttype {get; set;}
        public String align {get;set;}
        public Boolean editable {get;set;}
        public Boolean hidden {get;set;}
        public Boolean hidedlg {get;set;}
        public String formatter {get;set;}
        public Boolean search {get;set;}
        public string cellattr {get;set;}
        public string width {get;set;}
        public FormatOptions formatoptions {get;set;}
        public Searchoptions searchoptions{get;set;}
        public Boolean key {get;set;}
        public Boolean resizable{ get; set; }
		public String stype ='text';
		public Boolean sortable{ get; set; }
		public Boolean frozen{ get; set; }
		public Boolean fixed{ get; set; }
		public String summaryType{get;set;}
		public String classes{get;set;}
        
        public ColumnModel(){
        }
        
        public ColumnModel(String name, String index, String sorttype, String align, Boolean editable, Boolean hidden, Boolean hidedlg, String formatter, Boolean search){
            this.name = name;
            this.index = index;
            this.sorttype = sorttype;
            this.align = align;
            this.editable = editable;
            this.hidden = hidden;
            this.hidedlg = hidedlg;
            this.formatter = formatter;
            this.search = search;
        }
        public ColumnModel(String name, String index, Boolean key, Boolean hidden, String width, Boolean fixed,Boolean frozen,Boolean sortable, String formatter,Boolean search, String stype){
               this.name = name;
               this.index = index;
               this.key = key;
               this.hidden = hidden;
               this.width = width;
               this.fixed = fixed;
               this.frozen = frozen;
               this.sortable=sortable;
               this.formatter = formatter;
               this.search = search;
               this.resizable = false;
               this.stype = stype;
         }
    }
    
    public class FormatOptions{
        public String urlField {get; set;}
        public String addSlash {get; set;}
        public String target {get; set;}
        public String srcformat {get; set;}
        public String newformat{get; set;}
        public string todayDate {get;set;}
        public Boolean disabled{ get; set; }
        public string prefix {get;set;}
        public FormatOptions(String strUrlField, String strAddSlash, String strTarget, String strSrcFormat, String strNewFormat, String strTodayDate){
            this.urlField = strUrlField;
            this.addSlash = strAddSlash;
            this.target = strTarget;
            this.srcformat = strSrcFormat;
            this.newformat= strNewFormat;
            this.todayDate = strTodayDate;
        }
        
       public FormatOptions(String strUrlField, String strAddSlash, String strTarget, String strSrcFormat, String strNewFormat){
            this.urlField = strUrlField;
            this.addSlash = strAddSlash;
            this.target = strTarget;
            this.srcformat = strSrcFormat;
            this.newformat= strNewFormat;
        }
        
       public Formatoptions(Boolean disabled){
            this.disabled = disabled;
       }
       
       public Formatoptions(String currency_USD){
            this.prefix = currency_USD;
       }
        
    }
    
    public class SearchOptions{
        public String dataInit {get; set;}
        public Boolean clearSearch {get; set;}
        public List<String> sopt {get; set;}
        public String value{ get; set; }
        public SearchOptions(String strDataInit, Boolean blnClearSearch, List<String> listSOPT){
            this.dataInit = strDataInit;
            this.clearSearch = blnClearSearch;
            this.sopt = listSOPT;
        }
        public SearchOptions(String strDataInit, Boolean blnClearSearch, List<String> listSOPT, String value){
            this.dataInit = strDataInit;
            this.clearSearch = blnClearSearch;
            this.sopt = listSOPT;
            this.value = value;
        }
        public SearchOptions(List<String> listSOPT,String value){
            this.sopt = listSOPT;
            this.value = value;
        }
    }
    
    public class ColumnSearchConfiguration{
        public String strColumnModelName{get;set;}
        public Boolean blnAllowSearch{get;set;}
        public String strSearchTitle{get;set;}
        public ColumnSearchConfiguration(String strColumnModelName, Boolean blnAllowSearch, String strSearchTitle){
            this.strColumnModelName = strColumnModelName;
            this.blnAllowSearch = blnAllowSearch;
            this.strSearchTitle = strSearchTitle;
        }
    }
    
    public class FieldSetMember {

        public FieldSetMember(Schema.FieldSetMember f) {
            this.fieldPath = f.fieldPath;
            this.label = f.label;
            this.type = string.valueOf(f.getType());
        }
    
        @AuraEnabled
        public String fieldPath { get;set; }
    
        @AuraEnabled
        public String label { get;set; }
        
        @AuraEnabled
        public String type { get; set; }
    }
}