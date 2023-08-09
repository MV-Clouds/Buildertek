public class BOMSettingsController {
    
    public Boolean isUpdatethequantity{get;set;}
    public Boolean isShowFabricationTaxes{get;set;}
    public BOMSettingsController (){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings'];
        isUpdatethequantity = adminInterfaceNodeConfigurations.buildertek__Update_Quantity__c;
        isShowFabricationTaxes = adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c != null ? adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c : false;
    }
    
    public void onCreateChangeOrderonOverage(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings'];
        adminInterfaceNodeConfigurations.buildertek__Update_Quantity__c = isUpdatethequantity;
        adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c = isShowFabricationTaxes;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    } 
    
    @AuraEnabled 
    public static InnSettings getDefaultSettings()
    {
        
        
        String jsonSerializeFields='';
        String jsonSerializeFields1='';
        String jsonSerializeFields2='';
        
        String jsonSerializeFields3='';
        String jsonSerializeFields4='';
        String jsonSerializeFields5='';
        
        
        buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();
        list<buildertek__BOM_Settings__c>  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,
                                                           buildertek__BOM_Line_Selected_Fileds__c,
                                                           buildertek__Product_Selected_Fields__c,
                                                           buildertek__BOM_Line_Filter_Fields__c,
                                                           buildertek__Takeoff_Filter_Fields__c,
                                                           buildertek__Product_Filter_Fields__c
                                                           From buildertek__BOM_Settings__c 
                                                           limit 1];
        
        
        
        
        
        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        if(settingsList.size()>0)
        {//22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
            
            settingsrec =  settingsList[0]; 
            if(settingsList[0].buildertek__BOM_Selected_Fields__c !=null){
                jsonSerializeFields = settingsList[0].buildertek__BOM_Selected_Fields__c;      
            } else{
                jsonSerializeFields = FieldsDefaultValues;
            }                     
            
            if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                jsonSerializeFields2 = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
            } else{
                
                jsonSerializeFields2 = FieldsDefaultValues;
            }
            
            if(settingsList[0].buildertek__Product_Selected_Fields__c !=null){
                jsonSerializeFields1 = settingsList[0].buildertek__Product_Selected_Fields__c;      
            } else{
                FieldsDefaultValues = '[{"label":"Product Name","value":"Name"}]'; 
                jsonSerializeFields1 = FieldsDefaultValues;
            }
            
            //filter
            if(settingsList[0].buildertek__Takeoff_Filter_Fields__c !=null){
                jsonSerializeFields3 = settingsList[0].buildertek__Takeoff_Filter_Fields__c;      
            } else{
                jsonSerializeFields3 = FieldsDefaultValues;
            }                     
            
            if(settingsList[0].buildertek__Product_Filter_Fields__c !=null){
                jsonSerializeFields4 = settingsList[0].buildertek__Product_Filter_Fields__c;      
            } else{
                 FieldsDefaultValues = '[{"label":"Product Name","value":"Name"}]'; 
                jsonSerializeFields4 = FieldsDefaultValues;
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
            jsonSerializeFields =   FieldsDefaultValues;
            jsonSerializeFields1 =  FieldsDefaultValues;
            jsonSerializeFields2 =  FieldsDefaultValues;
            
            jsonSerializeFields3 =   FieldsDefaultValues;
            jsonSerializeFields4 =  FieldsDefaultValues;
            jsonSerializeFields5 =  FieldsDefaultValues;
        }//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
        
        
        
        // object for Inner Class
        InnSettings Inn = new InnSettings();        
        list<string> FieldsList=new list<string>();
        Map<string,string> ResultMap = new Map<string,string>();        
        
        List<Schema.SObjectType> objects = new List<Schema.SObjectType>{ buildertek__Project_Takeoff_Lines__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap.put(fieldName,fieldLabel);     
                    FieldsList.add(fieldName);                                                                        
                }
            }
        list<fieldWrap> FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        String jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields,
            List<fieldWrap>.class);
        Inn.TakeOffFieldSettings = FieldsSettings;           
        List<fieldWrap> AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeAvailableFields,
            List<fieldWrap>.class);
        Inn.AvailableOptions = AvailableOptions;   
        
        
        Map<string,string> ResultMap1 = new Map<string,string>();  
        list<string> FieldsList1=new list<string>();
        objects = new List<Schema.SObjectType>{ Product2.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap1.put(fieldName,fieldLabel);     
                    FieldsList1.add(fieldName);                                                                        
                }
            }
        FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList1)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap1.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields1,
            List<fieldWrap>.class);
        Inn.ProductFieldSettings = FieldsSettings;           
        AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeAvailableFields,
            List<fieldWrap>.class);
        Inn.AvailableProductOptions = AvailableOptions;
        
        
        Map<string,string> ResultMap2 = new Map<string,string>(); 
        list<string> FieldsList2=new list<string>();
        objects = new List<Schema.SObjectType>{ buildertek__Select_Sheet__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap2.put(fieldName,fieldLabel);     
                    FieldsList2.add(fieldName);                                                                        
                }
            }
        FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList2)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap2.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields2,
            List<fieldWrap>.class);
        Inn.BOMLineFieldSettings = FieldsSettings;           
        AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeAvailableFields,
            List<fieldWrap>.class);
        Inn.AvailableBOMLineOptions = AvailableOptions;
        
        
        //takeoff filter
         Map<string,string> ResultMap3 = new Map<string,string>(); 
        list<string> FieldsList3=new list<string>();
        objects = new List<Schema.SObjectType>{ buildertek__Project_Takeoff_Lines__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap3.put(fieldName,fieldLabel);     
                    FieldsList3.add(fieldName);                                                                        
                }
            }
        FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList3)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap3.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields3,List<fieldWrap>.class);
        Inn.TakeoffFilterFieldSettings = FieldsSettings;           
        AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeAvailableFields, List<fieldWrap>.class);
        Inn.AvailableTakeoffFilterOptions = AvailableOptions;
        
        //productFilter
        Map<string,string> ResultMap4 = new Map<string,string>(); 
        list<string> FieldsList4=new list<string>();
        objects = new List<Schema.SObjectType>{ Product2.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){                                       
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    
                    ResultMap4.put(fieldName,fieldLabel);     
                    FieldsList4.add(fieldName);                                                                        
                }
            }
        FieldsWraplist = new list<fieldWrap>();
        for(String fieldNamerec : FieldsList4)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = fieldNamerec;
            String fieldLabel = ResultMap4.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            FieldsWraplist.add(wrap);                 
        }                        
        jsonSerializeAvailableFields = JSON.serialize(FieldsWraplist);        
        
        
        FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields4,List<fieldWrap>.class);
        Inn.ProductFilterFieldSettings = FieldsSettings;           
        AvailableOptions = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeAvailableFields, List<fieldWrap>.class);
        Inn.AvailableProductFilterOptions = AvailableOptions;
        
        
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
        public list<fieldWrap> TakeOffFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableOptions{ get; set; } 
        
        @AuraEnabled
        public list<fieldWrap> ProductFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableProductOptions{ get; set; } 
        
        @AuraEnabled
        public list<fieldWrap> BOMLineFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableBOMLineOptions{ get; set; } 
        
        @AuraEnabled
        public list<fieldWrap> TakeoffFilterFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableTakeoffFilterOptions{ get; set; } 
        
        @AuraEnabled
        public list<fieldWrap> ProductFilterFieldSettings{ get; set; } 
        @AuraEnabled
        public list<fieldWrap> AvailableProductFilterOptions{ get; set; } 
        
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
    public static string saveBOMSetting( string BOMFieldsSelectedValues,string ProductFieldsSelectedValues ,string BOMLineFieldsSelectedValues ,string TakeoffFilterSelectedValues,string ProductFilterSelectedValues,string BOMLineFilterSelectedValues)
    {   
        
        string msg = '';
        
        buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();
        list<buildertek__BOM_Settings__c>  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,buildertek__BOM_Line_Selected_Fileds__c,buildertek__Product_Selected_Fields__c, buildertek__BOM_Line_Filter_Fields__c,
                                                           buildertek__Takeoff_Filter_Fields__c,
                                                           buildertek__Product_Filter_Fields__c
                                                           From buildertek__BOM_Settings__c 
                                                           limit 1];
        
        
        
        
        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';                       
        if(settingsList.size()>0){
            settingsrec =  settingsList[0]; 
        }else{
            buildertek__BOM_Settings__c settingsrec1 = new buildertek__BOM_Settings__c();
            settingsrec1.Name = 'BOM Settings';
            insert settingsrec1;
            settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,buildertek__BOM_Line_Selected_Fileds__c,buildertek__Product_Selected_Fields__c,buildertek__BOM_Line_Filter_Fields__c,
                                                           buildertek__Takeoff_Filter_Fields__c,
                                                           buildertek__Product_Filter_Fields__c
                            From buildertek__BOM_Settings__c 
                            limit 1];
            settingsrec =  settingsList[0];
        }                        
        
        // generate json string for Case Fields Selected Values
        // getting Field, Label Map from Case Object
        Map<string,string> ResultMap = new Map<string,string>();
        
        List<Schema.SObjectType> objects = new List<Schema.SObjectType>{ buildertek__Project_Takeoff_Lines__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    
                    //System.debug('API Field Name =  '+fld.getDescribe().getName());
                    
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap.put(fieldName,fieldLabel);               
                }
            }
        //End getting Field, Label Map from Case Object                                          
        
        
        // generating list and json using Map field,label                                      
        list<fieldWrap> InnerSettingsFieldslist = new list<fieldWrap>();
        String[] arrayBOMFields = BOMFieldsSelectedValues.split(',');
        for(integer i=0;i<arrayBOMFields.size();i++)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = arrayBOMFields[i];
            String fieldLabel = ResultMap.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            InnerSettingsFieldslist.add(wrap);                 
        }                                                              
        String jsonBOMFields = JSON.serialize(InnerSettingsFieldslist);
        system.debug('jsonBOMFields---->'+jsonBOMFields);
        //End generating list and json using Map field,label                                      
        
        
        objects = new List<Schema.SObjectType>{ Product2.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    
                    //System.debug('API Field Name =  '+fld.getDescribe().getName());
                    
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap.put(fieldName,fieldLabel);               
                }
            }
        //End getting Field, Label Map from Case Object                                          
        
        
        // generating list and json using Map field,label                                      
        InnerSettingsFieldslist = new list<fieldWrap>();
        arrayBOMFields = ProductFieldsSelectedValues.split(',');
        for(integer i=0;i<arrayBOMFields.size();i++)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = arrayBOMFields[i];
            String fieldLabel = ResultMap.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            InnerSettingsFieldslist.add(wrap);                 
        }                                                              
        String jsonBOMFields1 = JSON.serialize(InnerSettingsFieldslist);
        system.debug('jsonBOMFields---->'+jsonBOMFields1);
        //End generating list and json using Map field,label                                      
        
        
        objects = new List<Schema.SObjectType>{ buildertek__Select_Sheet__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    
                    //System.debug('API Field Name =  '+fld.getDescribe().getName());
                    
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap.put(fieldName,fieldLabel);               
                }
            }
        //End getting Field, Label Map from Case Object                                          
        
        
        // generating list and json using Map field,label                                      
        InnerSettingsFieldslist = new list<fieldWrap>();
        arrayBOMFields = BOMLineFieldsSelectedValues.split(',');
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
        
        
        
        // takeoff
        Map<string,string> ResultMap1 = new Map<string,string>();
          objects = new List<Schema.SObjectType>{buildertek__Project_Takeoff_Lines__c.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap1.put(fieldName,fieldLabel);               
                }
            }                                     
        InnerSettingsFieldslist = new list<fieldWrap>();
        arrayBOMFields =  TakeoffFilterSelectedValues.split(',');
        for(integer i=0;i<arrayBOMFields.size();i++)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = arrayBOMFields[i];
            String fieldLabel = ResultMap1.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            InnerSettingsFieldslist.add(wrap);                 
        }                                                              
        String jsonBOMFields3 = JSON.serialize(InnerSettingsFieldslist);
        system.debug('jsonBOMFields---->'+jsonBOMFields3);
        
        
        //product
        Map<string,string> ResultMap2 = new Map<string,string>();
         objects = new List<Schema.SObjectType>{Product2.SObjectType};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    String fieldName = fld.getDescribe().getName();                
                    String fieldLabel = fld.getDescribe().getLabel();
                    ResultMap2.put(fieldName,fieldLabel);               
                }
            }                                     
        InnerSettingsFieldslist = new list<fieldWrap>();
        arrayBOMFields =  ProductFilterSelectedValues.split(',');
        for(integer i=0;i<arrayBOMFields.size();i++)
        {
            fieldWrap wrap = new fieldWrap();    
            String fieldName = arrayBOMFields[i];
            String fieldLabel = ResultMap2.get(fieldName);
            
            wrap.label=fieldLabel;
            wrap.value=fieldName;
            InnerSettingsFieldslist.add(wrap);                 
        }                                                              
        String jsonBOMFields4 = JSON.serialize(InnerSettingsFieldslist);
        system.debug('jsonBOMFields---->'+jsonBOMFields4);
        //End generating list and json using Map field,label     
        //
        
        
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
      
        
        settingsrec.buildertek__BOM_Selected_Fields__c = jsonBOMFields;
        settingsrec.buildertek__Product_Selected_Fields__c = jsonBOMFields1;
        settingsrec.buildertek__BOM_Line_Selected_Fileds__c = jsonBOMFields2;
        settingsrec.buildertek__Takeoff_Filter_Fields__c = jsonBOMFields3;
        settingsrec.buildertek__Product_Filter_Fields__c = jsonBOMFields4;
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