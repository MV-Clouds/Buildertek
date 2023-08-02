public class BOMLineSettingsController {
   
    
    @AuraEnabled 
    public static InnSettings getDefaultSettings()
    {
        
        
        String jsonSerializeFields='';
        String jsonSerializeFields1='';
        String jsonSerializeFields2='';
        
        String jsonSerializeFields3='';
        String jsonSerializeFields4='';
        String jsonSerializeFields5='';
        
        
        buildertek__BOM_Line_Setting__c settingsrec = new buildertek__BOM_Line_Setting__c();
        list<buildertek__BOM_Line_Setting__c>  settingsList = [Select id,Name,
                                                           buildertek__BOM_Line_Selected_Fileds__c,                                                          
                                                           buildertek__BOM_Line_Filter_Fields__c
                                                           From buildertek__BOM_Line_Setting__c 
                                                           limit 1];
        
        
        
        
        
        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        if(settingsList.size()>0)
        {//22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
            
            settingsrec =  settingsList[0];                               
            
            if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                jsonSerializeFields2 = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
            } else{
                
                jsonSerializeFields2 = FieldsDefaultValues;
            }                      
            if(settingsList[0].buildertek__BOM_Line_Filter_Fields__c !=null){
                jsonSerializeFields5 = settingsList[0].buildertek__BOM_Line_Filter_Fields__c;      
            } else{
               
                jsonSerializeFields5 = FieldsDefaultValues;
            }
            
        }//22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222         
        else        // if no records, take default values
            // STATUS default values : take all values of a picklist
            // CATEGORIES default values : take all values of a picklist
            // New Ticket default values : 
        {//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333                                       
            jsonSerializeFields2 =  FieldsDefaultValues;
            jsonSerializeFields5 =  FieldsDefaultValues;
        }//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
         
        InnSettings Inn = new InnSettings();        
        Map<string,string> ResultMap2 = new Map<string,string>(); 
        list<string> FieldsList2=new list<string>();
        List<Schema.SObjectType> objects = new List<Schema.SObjectType>{ buildertek__Select_Sheet__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap2.put(fieldName,fieldLabel);     
                    FieldsList2.add(fieldName);                                                                        
                }
            }
        list<fieldWrap> FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList2)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap2.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        String jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields2,
            List<fieldWrap>.class);
        Inn.BOMLineFieldSettings = FieldsSettings;           
        list<fieldWrap> AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeAvailableFields,
            List<fieldWrap>.class);
        Inn.AvailableBOMLineOptions = AvailableOptions;
        
        
      
          
        
         //BOM Line filter
        Map<string,string> ResultMap5 = new Map<string,string>(); 
        list<string> FieldsList5=new list<string>();
        objects = new List<Schema.SObjectType>{buildertek__Select_Sheet__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap5.put(fieldName,fieldLabel);     
                    FieldsList5.add(fieldName);                                                                        
                }
            }
        FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList5)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap5.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields5,List<fieldWrap>.class);
        Inn.BOMLineFilterFieldSettings = FieldsSettings;           
        AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeAvailableFields, List<fieldWrap>.class);
        Inn.AvailableBOMLineFilterOptions = AvailableOptions;
        
        return Inn;
        
    }
    
    
    public class InnSettings{
        
        @AuraEnabled
        public list<fieldWrap> BOMLineFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableBOMLineOptions{ get; set; } 
        
       
        @AuraEnabled
        public list<fieldWrap> BOMLineFilterFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableBOMLineFilterOptions{ get; set; } 
    }
    
    public class fieldWrap{
        @AuraEnabled
        public string label{ get; set; }    
        @AuraEnabled
        public string value{ get; set; }    
    }
    
    @AuraEnabled 
    public static string saveBOMSetting( string BOMLineFieldsSelectedValues , string BOMLineFilterSelectedValues)
    {   
        
        string msg = '';
        
        buildertek__BOM_Line_Setting__c settingsrec = new buildertek__BOM_Line_Setting__c();
        list<buildertek__BOM_Line_Setting__c>  settingsList = [Select id,Name, buildertek__BOM_Line_Selected_Fileds__c,buildertek__BOM_Line_Filter_Fields__c                                                          
                                                           From buildertek__BOM_Line_Setting__c 
                                                           limit 1];
        
        
        
        
        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';                       
        if(settingsList.size()>0){
            settingsrec =  settingsList[0]; 
        }else{
            buildertek__BOM_Line_Setting__c settingsrec1 = new buildertek__BOM_Line_Setting__c();
            settingsrec1.Name = 'BOM Line Settings';
            insert settingsrec1;
            settingsList = [Select id,Name, buildertek__BOM_Line_Selected_Fileds__c,buildertek__BOM_Line_Filter_Fields__c 
                            From buildertek__BOM_Line_Setting__c 
                            limit 1];
            settingsrec =  settingsList[0];
        }                        
        
        // generate json string for Case Fields Selected Values
        // getting Field, Label Map from Case Object
        Map<string,string> ResultMap = new Map<string,string>();
        
        List<Schema.SObjectType> objects = new List<Schema.SObjectType>{ buildertek__Select_Sheet__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    
                    //System.debug('API Field Name =  '+fld.getDescribe().getName());
                    
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap.put(fieldName,fieldLabel);               
                }
            }
        //End getting Field, Label Map from Case Object                                          
        
        list<fieldWrap> InnerSettingsFieldslist = new list<fieldWrap>();
        // generating list and json using Map field,label                                      
        InnerSettingsFieldslist = new list<fieldWrap>();
        String[] arrayBOMFields = BOMLineFieldsSelectedValues.split(',');
        for(integer i=0;i<arrayBOMFields.size();i++)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = arrayBOMFields[i];
            String fieldLabel = ResultMap.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            InnerSettingsFieldslist.add(wrap);                 
        }                                                              
        String jsonBOMFields2 = JSON.serialize(InnerSettingsFieldslist);
        system.debug('jsonBOMFields---->'+jsonBOMFields2);
        //End generating list and json using Map field,label                                      
        
        
          
         //BOM line filter
         Map<string,string> ResultMap3 = new Map<string,string>();
         objects = new List<Schema.SObjectType>{buildertek__Select_Sheet__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap3.put(fieldName,fieldLabel);               
                }
            }                                     
        InnerSettingsFieldslist = new list<fieldWrap>();
        arrayBOMFields =  BOMLineFilterSelectedValues.split(',');
        for(integer i=0;i<arrayBOMFields.size();i++)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = arrayBOMFields[i];
            String fieldLabel = ResultMap3.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            InnerSettingsFieldslist.add(wrap);                 
        }                                                              
        String jsonBOMFields5 = JSON.serialize(InnerSettingsFieldslist);
        system.debug('jsonBOMFields---->'+jsonBOMFields5);
        //End generating list and json using Map field,label     
      
        
        settingsrec.buildertek__BOM_Line_Selected_Fileds__c = jsonBOMFields2;
        settingsrec.buildertek__BOM_Line_Filter_Fields__c = jsonBOMFields5;
        try{
            upsert settingsrec;
            msg = 'saved';
        }catch(Exception e){
            system.debug('exception '+e.getMessage()); 
        }
        
        return msg;
        
    }
    

}