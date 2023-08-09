/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_ApplicationConfigurationController
* Created by Sagar: 20/08/2017
*
* - Configure all Application configuration

* - Modifications:
* - Sagar, 20/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_ApplicationConfigurationController {
    public Boolean isError{get; set;}
    public Map<String, Application_Configuration__c> appConfigByName;
    public Map<String, Amazon_S3_Key__c> awsS3KeyByName;
    public Map<String, WrappedAppConfig> wrappedAppConfigByName;
    public List<WrappedAppConfig> appData {get;set;}
    public Folder__c newBucketFolder {get; set;}
    public List<BucketInfo> bucketsToMap{get;set;}                                                  //All available buckets 
    public string strInvalidBucketName {get;set;}                                               //Error message if the bucket name is invalid
    public Boolean isShowNewBucket{get; set;}
    public Boolean isShowMapBucket{get; set;}
    public List<BucketInfo> configuredBuckets{get; set;}
    public S3.AmazonS3 as3 { get; private set; }                            //This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS. 
    public Boolean isAmazonCredentialProvided{get; set;}
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_ApplicationConfigurationController(){
        //Set the default value for all variables
        isError = false;
        isShowNewBucket = false;
        isShowMapBucket = false;
        isAmazonCredentialProvided = false;
        
        newBucketFolder = new Folder__c();
        strInvalidBucketName = '';
        
        bucketsToMap = new List<BucketInfo>();
        
        appConfigByName = new Map<String, Application_Configuration__c>();
        awsS3KeyByName = new Map<String, Amazon_S3_Key__c>();
        wrappedAppConfigByName = new Map<String, WrappedAppConfig>();
        
        appData = new List<WrappedAppConfig>();
        appData = getApplicationConfigurationData();
        
        configuredBuckets = new List<BucketInfo>();
        configuredBuckets = getConfiguredBuckets();
        
    }
    
    /*
    *   Purpose:    Initialize the controller
    *   Parameters: 
    *   UnitTests:  
    */
    public void init(){
         try{
             User currentUser;
             if (Schema.sObjectType.Profile.fields.Name.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible()) {
                currentUser = [Select Id, Profile.Name From User Where Id = :UserInfo.getUserId() LIMIT 1];    
             }
            
            if(currentUser.Profile.Name != 'System Administrator'){
                throw new BT_ApplicationException(System.Label.Page_Access_Error);
            }
        } catch(Exception e){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return;
        }
    }
    
    /*
    *   Purpose:    Get all application configuration data and prepare wrapper class to display on page.
    *   Parameters: 
    *   UnitTests:  
    */
    public List<WrappedAppConfig> getApplicationConfigurationData() { 
        isAmazonCredentialProvided = false;
        appConfigByName.clear();
        awsS3KeyByName.clear();
        wrappedAppConfigByName.clear();
        List<Application_Configuration__c> appConfig;
        if(Schema.sObjectType.Application_Configuration__c.fields.Name.isAccessible()
            && Schema.sObjectType.Application_Configuration__c.fields.Label__c.isAccessible()
            && Schema.sObjectType.Application_Configuration__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.Application_Configuration__c.fields.Display_Layout__c.isAccessible()
            && Schema.sObjectType.Application_Configuration__c.fields.Configured_Value__c.isAccessible()){
            appConfig = [Select name, Label__c, Description__c, Display_Layout__c, Configured_Value__c from Application_Configuration__c Order By Name asc Limit 1000];    
        }
        for(Application_Configuration__c appConfigEntry : appConfig){
            appConfigByName.put(appConfigEntry.name, appConfigEntry);
            if(appConfigEntry.name != BT_Constants.BUCKETS && appConfigEntry.name != BT_Constants.FILE_CLEANUP_JOBID && appConfigEntry.name != BT_Constants.FILE_IMPORT_JOBID && appConfigEntry.name != BT_Constants.AMAZON_CANONICAL_USERID ){
                wrappedAppConfigByName.put(appConfigEntry.name, new WrappedAppConfig(appConfigEntry.Label__c, appConfigEntry.Description__c, appConfigEntry.Configured_Value__c, appConfigEntry.Display_Layout__c));
            }
        }
        List<Amazon_S3_Key__c> awsS3Key;
        if(Schema.sObjectType.Amazon_S3_Key__c.fields.Name.isAccessible()
            && Schema.sObjectType.Amazon_S3_Key__c.fields.Label__c.isAccessible()
            && Schema.sObjectType.Amazon_S3_Key__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.Amazon_S3_Key__c.fields.Configured_Value__c.isAccessible()){
            awsS3Key = [Select name, Label__c, Description__c, Configured_Value__c from Amazon_S3_Key__c Order By Name asc Limit 1000];    
        }
        for(Amazon_S3_Key__c awsS3KeyEntry : awsS3Key){
            awsS3KeyByName.put(awsS3KeyEntry.name, awsS3KeyEntry);
            wrappedAppConfigByName.put(awsS3KeyEntry.name, new WrappedAppConfig(awsS3KeyEntry.Label__c, awsS3KeyEntry.Description__c, awsS3KeyEntry.Configured_Value__c, awsS3KeyEntry.name == BT_Constants.AWS_SECRET_KEY ? 'Secret Text' : 'Simple Text'));
        }
        
        List<String> configNames = new List<String>();
        configNames.addAll(wrappedAppConfigByName.keySet());
        configNames.sort();
        
        List<WrappedAppConfig> appData = new List<WrappedAppConfig>();
        for(String configName : configNames){
            appData.add(wrappedAppConfigByName.get(configName));
        }
        
        if(awsS3KeyByName.get(BT_Constants.AWS_PUBLIC_KEY) != null && awsS3KeyByName.get(BT_Constants.AWS_PUBLIC_KEY).Configured_Value__c != null && awsS3KeyByName.get(BT_Constants.AWS_PUBLIC_KEY).Configured_Value__c.trim() != '' &&
                awsS3KeyByName.get(BT_Constants.AWS_SECRET_KEY) != null && awsS3KeyByName.get(BT_Constants.AWS_SECRET_KEY).Configured_Value__c != null && awsS3KeyByName.get(BT_Constants.AWS_SECRET_KEY).Configured_Value__c.trim() != ''){
           isAmazonCredentialProvided = true; 
        }
        
        return appData;
    }
    
    /*
    *   Purpose:    Returs the list of all buckets linked to saleforce.
    *   Parameters: 
    *   UnitTests:  
    */
    public List<BucketInfo> getConfiguredBuckets(){
        List<String> fields = new List<String>{'Id', 'Name', 'Description__c', 'Default__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        List<Folder__c> bucketFolders = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Parent__c = null AND Active__c = true'));
        for(Folder__c bucketFolder : bucketFolders){
            configuredBuckets.add(new BucketInfo(bucketFolder.Id, bucketFolder.Name, bucketFolder.Description__c, '', true, bucketFolder.Default__c));
        }
        return configuredBuckets;
    }
    
    /*
    *   Purpose:    Show poup for new bucket.
    *   Parameters: 
    *   UnitTests:  
    */
    public void showNewBucket(){
        isShowNewBucket = true;
        newBucketFolder = new Folder__c();
        //Fetching the configuration. That will be used to fetch all AWs buckets
        as3 = new S3.AmazonS3(wrappedAppConfigByName.get(BT_Constants.AWS_PUBLIC_KEY).configuredValue, wrappedAppConfigByName.get(BT_Constants.AWS_SECRET_KEY).configuredValue);
    }
    
    /*
    *   Purpose:    Hide poup for new bucket.
    *   Parameters: 
    *   UnitTests:  
    */
    public void hideNewBucket(){
        isShowNewBucket = false;
        strInvalidBucketName = '';
    }
    
    /*
    *   Purpose:    Show poup for map bucket.
    *   Parameters: 
    *   UnitTests:  
    */
    public void showMapBucket(){
        getBucketsToMap();
        if(bucketsToMap != null){
            isShowMapBucket = true;
        }
    }
    
    /*
    *   Purpose:    Hide poup for map bucket.
    *   Parameters: 
    *   UnitTests:  
    */
    public void hideMapBucket(){
        isShowMapBucket = false;
    }
    
    /*
    *   Purpose:    Map selectedc amazon buckets to saleforce.
    *   Parameters: 
    *   UnitTests:  
    */
    public void mapBuckets(){
        //List of folders need to be inserted or updated
        List<Folder__c> lstFolderBucket = new List<Folder__c>();
        map<string,Folder__c> mapAllFolderBucket = new map<string,Folder__c>();
        List<String> fields = new List<String>{'Id', 'Name', 'Active__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        for(Folder__c obj : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Folder__c Where Parent__c = null'))){
            mapAllFolderBucket.put(obj.Name,obj);
        }
        
        set<string> setDoInactive = new set<String>();
        
        //Went through all selected buckets and make them active if folder is already created and create incase folder is not created.
        for(BucketInfo str :bucketsToMap){
            if(mapAllFolderBucket.containsKey(str.name)){
                //Here folder for bucket is already created so we just need to activate it.
                Folder__c objFolder = new Folder__c();
                objFolder.id = mapAllFolderBucket.get(str.name).id;
                objFolder.Active__c = str.isSelected;
                objFolder.Default__c = str.isDefault;
                objFolder.Description__c = str.folder.Description__c;
                lstFolderBucket.add(objFolder);
            } else if(str.isSelected){
                //Here folder is not created for selected bucket so we will create new folder for them
                Folder__c objFolder = new Folder__c();
                objFolder.Name = str.name;
                objFolder.Description__c = str.folder.Description__c;
                objFolder.Active__c = true;
                objFolder.Default__c = str.isDefault;
                lstFolderBucket.add(objFolder);
            }
            
            //Check for duplicate folder name
            try{
                DMLManager.upsertAsUser(lstFolderBucket);
            } catch(DMLException ex){
                strInvalidBucketName = ex.getDmlMessage(0);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0)));
                return;
            } catch(Exception ex){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
                ApexPages.addMessage(errorMsg);
                return;
            }
        }
        
        configuredBuckets = new List<BucketInfo>();
        configuredBuckets = getConfiguredBuckets();
        hideMapBucket();
    }
    
    /*
    *   Purpose:    Unlink amazon bucket which is linked to salesforce.
    *   Parameters: 
    *   UnitTests:  
    */
    public void removeBucketMap(){
        String bucketId = ApexPages.currentPage().getParameters().get('bucketToRemoveMap');
        List<String> fields = new List<String>{'Id', 'Name', 'Active__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        List<Folder__c> buckets = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c where Id =: bucketId'));
        for(Folder__c bucket : buckets){
            if(Schema.sObjectType.Folder__c.fields.Active__c.isUpdateable() && Schema.sObjectType.Folder__c.fields.Default__c.isUpdateable()){
                bucket.Active__c = false;
                bucket.Default__c = false;
                
            }
        }
        if(!buckets.isEmpty()){
            update buckets;
        }
        // Set default bucket
        setDefaultBucket();
        
        configuredBuckets = new List<BucketInfo>();
        configuredBuckets = getConfiguredBuckets();
    }
    
    /*
    *   Purpose:    To set the defaul bucket whenever any new bucket gets added or removed.
    *   Parameters: 
    *   UnitTests:  
    */
    private void setDefaultBucket(){
        List<String> fields = new List<String>{'Id', 'Default__c', 'Active__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        List<Folder__c> activeBuckets = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c where Active__c = true'));
        Boolean isDefaultAvailable = false;
        for(Folder__c activeBucket : activeBuckets){
            if(activeBucket.Default__c){
                isDefaultAvailable = true;
                break;
            }
        }
        if(!isDefaultAvailable && !activeBuckets.isEmpty()){
            activeBuckets[0].Default__c = true;
             if(Schema.sObjectType.Folder__c.fields.Default__c.isUpdateable()){
            update activeBuckets[0];
             }
        }
    }
    
    /*
    *   Executed:   On page load if configuration is already done. Also while user will click "Save" after providing key and secret
    *   Purpose:    To fetch all available AWs buckets and rendere the next buttom on page
    *   Parameters: 
    *   UnitTests:  
    */
    public void getBucketsToMap(){
        //If the configuration is already done then we will display "Next" butoon with all available buckets. Previosly selected buckets will come as selected on page load
        Amazon_S3_Key__c configurationForPublicKey = awsS3KeyByName.get(BT_Constants.AWS_PUBLIC_KEY);
        Amazon_S3_Key__c configurationForSecretKey = awsS3KeyByName.get(BT_Constants.AWS_SECRET_KEY);
        if(configurationForPublicKey != null && configurationForSecretKey != null){
            if(configurationForPublicKey.Configured_Value__c != null && configurationForSecretKey.Configured_Value__c != null && configurationForPublicKey.Configured_Value__c != '' && configurationForSecretKey.Configured_Value__c != ''){
                //Fetchin all available AWS buckets
                bucketsToMap = getAmazonBucketsToMap();
            }
        }
    }
    
    /*
    *   Executed:   On page load, to get the list of all available amnazon buckets
    *   Purpose:    To fetch all available AWs buckets 
    *   Parameters: 
    *   UnitTests:  
    */
    public List<BucketInfo> getAmazonBucketsToMap() {
        map<string,Folder__c> mapAllFolderBucket = new map<string,Folder__c>();
        List<String> fields = new List<String>{'Id', 'Name', 'Description__c', 'Active__c', 'Default__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        for(Folder__c obj :  Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Folder__c Where Parent__c = null'))){
            mapAllFolderBucket.put(obj.Name,obj);
        }
        
        //Fetching the configuration. That will be used to fetch all AWs buckets
        as3 = new S3.AmazonS3(wrappedAppConfigByName.get(BT_Constants.AWS_PUBLIC_KEY).configuredValue, wrappedAppConfigByName.get(BT_Constants.AWS_SECRET_KEY).configuredValue);
        
        List<BucketInfo> awsBuckets = new List<BucketInfo>(); 
        
        Set<String> configuredBucketNames  = new Set<String>();
        for(BucketInfo bucketInfo : configuredBuckets){
            configuredBucketNames.add(bucketInfo.name);
        }
        
        try{
            Datetime now = Datetime.now();
            
            //This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account. 
            S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(as3.key,now,as3.signature('ListAllMyBuckets',now));
            S3.ListAllMyBucketsList bucketList = allBuckets.Buckets;
            S3.ListAllMyBucketsEntry[] buckets = bucketList.Bucket;
           
            //Loop through each bucket entry to get the bucket name and store in string array. 
            for(S3.ListAllMyBucketsEntry bucket: buckets){
                Folder__c bucketFolder =  mapAllFolderBucket.get(bucket.name);
                awsBuckets.add(new BucketInfo(bucketFolder != null ? bucketFolder.Id : null, bucket.name,bucketFolder != null ? bucketFolder.Description__c : '', '', bucketFolder != null ? bucketFolder.Active__c : false, bucketFolder != null ? bucketFolder.Default__c : false));
            }
            return awsBuckets;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Invalid_AWS_Access_Keys_Warning);
            ApexPages.addMessage(msg);
            return null;
        }
    }
    
    /*
    *   Executed:   On click of "Create Bucket"
    *   Purpose:    Creates bucket in Amazon with the provided name
    *   Parameters: 
    *   UnitTests:  
    */
    public void createNewBucket(){
       try{
           Datetime now = Datetime.now();
           //This performs the Web Service call to Amazon S3 and create a new bucket.
           String regex = '^[A-Za-z0-9](-*[A-Za-z0-9]){2,62}$';
           Pattern pat = Pattern.compile(regex);
           Matcher mat = pat.matcher(newBucketFolder.Name);
           if(!mat.matches()){
                strInvalidBucketName = System.Label.Invalid_Bucket_Name;
                return;
           }
           //Creating bucket
           S3.CreateBucketResult createBucketReslt = as3.CreateBucket(newBucketFolder.Name,null,as3.key,now,as3.signature('CreateBucket',now));
           
           //Adding new bucket as selected buckets and available buckets
           newBucketFolder.Active__c = true;
           //Check for duplicate folder name
           try{
                DMLManager.insertAsUser(newBucketFolder);
           } catch(DMLException ex){
               strInvalidBucketName = ex.getDmlMessage(0);
               return;
           }  catch(Exception ex){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
                ApexPages.addMessage(errorMsg);
                return;
            }
           // Set default bucket
           setDefaultBucket();
           //Update the list of buckets
           configuredBuckets = new List<BucketInfo>();
           configuredBuckets = getConfiguredBuckets();
           //Reset the values for new bucket
           newBucketFolder = new Folder__c();
           strInvalidBucketName = '';
           hideNewBucket();
       } catch(Exception ex){
           strInvalidBucketName = System.Label.Invalid_Bucket_Name;
       }
    }
    
    /*
    *   Executed:   On click of "Save"
    *   Purpose:    Save the credetials and other configuration like max file size and track file download.
    *   Parameters: 
    *   UnitTests:  
    */
    public void save() {
        for(String name : wrappedAppConfigByName.keySet()){
            WrappedAppConfig wrappedConfigEntry = wrappedAppConfigByName.get(name);
            Application_Configuration__c configEntry = appConfigByName.get(name);
            if(configEntry != null){
                configEntry.Configured_Value__c = wrappedConfigEntry.configuredValue;
            }
            Amazon_S3_Key__c awsS3KeyEntry = awsS3KeyByName.get(name);
            if(awsS3KeyEntry != null){
                awsS3KeyEntry.Configured_Value__c = wrappedConfigEntry.configuredValue;
            }
        }
        // Validate the AWS Access and Secret Key
        if(wrappedAppConfigByName.get(BT_Constants.AWS_PUBLIC_KEY).configuredValue != null && wrappedAppConfigByName.get(BT_Constants.AWS_SECRET_KEY).configuredValue != null){
            try{
                Datetime now = Datetime.now();
                as3 = new S3.AmazonS3(wrappedAppConfigByName.get(BT_Constants.AWS_PUBLIC_KEY).configuredValue, wrappedAppConfigByName.get(BT_Constants.AWS_SECRET_KEY).configuredValue);
                //This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account. 
                S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(as3.key,now,as3.signature('ListAllMyBuckets',now));
                if(allBuckets.Owner.Id != null){
                    BT_HomeUtils.setAmazonCanonicalUserId(allBuckets.Owner.Id);
                }
            } catch (Exception e) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.Invalid_AWS_Access_Keys_Warning);
                ApexPages.addMessage(msg);
                return;
            }
        }
        
        // Validate the Max File Size
        if(wrappedAppConfigByName.get(BT_Constants.MAX_FILE_SIZE).configuredValue != null && wrappedAppConfigByName.get(BT_Constants.MAX_FILE_SIZE).configuredValue.trim() != '' && !wrappedAppConfigByName.get(BT_Constants.MAX_FILE_SIZE).configuredValue.isNumeric()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Invalid_Max_File_Size_Warning));
            return;
        }
        upsert appConfigByName.values();
        upsert awsS3KeyByName.values();
        appData = getApplicationConfigurationData();
        return;
    }
    
    /*
    *   Purpose:    Get the select radio option for check box type of configuration.
    *   Parameters: 
    *   UnitTests:  
    */
    public List<SelectOption> getRadioOptions(){
       List<SelectOption> options = new List<SelectOption>(); 
       options.add(new SelectOption('true',System.Label.Yes)); 
       options.add(new SelectOption('false',System.Label.No)); 
       return options; 
    }  
    
    /*
    *   Purpose:    Initialize the system configuration
    *   Parameters: 
    *   UnitTests:  
    */
    public void initialize(){
        Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
        Map<String, Amazon_S3_Key__c> awsS3KeyMap = Amazon_S3_Key__c.getAll();
        
        // Set limit to maximum file size
        Application_Configuration__c config = appConfigurationMap.get(BT_Constants.MAX_FILE_SIZE);
        if(config == null){
            config  = new Application_Configuration__c(
                           Name = BT_Constants.MAX_FILE_SIZE, 
                           Label__c = System.Label.Max_File_Size_Configuration,
                           Configured_value__c = '',
                           Display_Layout__c = 'Simple Text',
                           Description__c = System.Label.Max_File_Size_Configuration_Description);
                                   
            DMLManager.insertAsUser(config);
        } else {
            config.Configured_Value__c = '';
            DMLManager.updateAsUser(config);
        }
        
        // Set organization wide email
        config = appConfigurationMap.get(BT_Constants.JOB_STATUS_FROM_EMAIL_ADDRESS);
        if(config == null){
            config  = new Application_Configuration__c(
                           Name = BT_Constants.JOB_STATUS_FROM_EMAIL_ADDRESS, 
                           Label__c = System.Label.Job_Status_From_Email_Address_Configuration,
                           Configured_value__c = '',
                           Display_Layout__c = 'Simple Text',
                           Description__c = System.Label.Job_Status_From_Email_Address_Configuration_Description);
                                   
            DMLManager.insertAsUser(config);
        } else {
            config.Configured_Value__c = '';
            DMLManager.updateAsUser(config);
        }
        
        // Property is used to enable/disable file download history.
        config = appConfigurationMap.get(BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY);
        if(config == null){
            config  = new Application_Configuration__c(
                           Name = BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY, 
                           Label__c =  System.Label.Track_File_Downloads_Configuration,
                           Configured_value__c = 'true',
                           Display_Layout__c = 'Radio',
                           Description__c = System.Label.Track_File_Downloads_Configuration_Description);
                                   
            DMLManager.insertAsUser(config);
        } else {
            config.Configured_Value__c = 'true';
            DMLManager.updateAsUser(config);
        }
        
        // Property is used to set the public key for AWS S3 API.
        Amazon_S3_Key__c awsS3Key = awsS3KeyMap.get(BT_Constants.AWS_PUBLIC_KEY);
        if(awsS3Key == null){
            awsS3Key  = new Amazon_S3_Key__c(
                           Name = BT_Constants.AWS_PUBLIC_KEY, 
                           Label__c =  System.Label.AWS_Access_Key_Id_Configuration,
                           Configured_value__c = '',
                           Description__c = System.Label.AWS_Access_Key_Id_Configuration_Description);
                                   
            DMLManager.insertAsUser(awsS3Key);
        }
        
        // Property is used to set the private key for AWS S3 API.
        awsS3Key = awsS3KeyMap.get(BT_Constants.AWS_SECRET_KEY);
        if(awsS3Key == null){
            awsS3Key  = new Amazon_S3_Key__c(
                           Name = BT_Constants.AWS_SECRET_KEY, 
                           Label__c =  System.Label.AWS_Secret_Key_Configuration,
                           Configured_value__c = '',
                           Description__c = System.Label.AWS_Secret_Key_Configuration_Description);
                                   
            DMLManager.insertAsUser(awsS3Key);
        }
        
        appData = new List<WrappedAppConfig>();
        appData = getApplicationConfigurationData();
        
        configuredBuckets = new List<BucketInfo>();
        configuredBuckets = getConfiguredBuckets();
        
    }
    
    /*
    Wrapper class to hold the application config information
    */
    public class WrappedAppConfig{
        public String name {get; set;}
        public String description {get; set;}
        public String configuredValue {get; set;}
        public String displayLayout {get; set;}
        public WrappedAppConfig( String name, String description, String configuredValue, String displayLayout){
            this.name = name;
            this.description = description;
            this.configuredValue = configuredValue;
            this.displayLayout = displayLayout;
        }
    }
    
    /*
    Wrapper class to hold the bucket information
    */
    public class BucketInfo{
        public String id {get; set;}
        public Boolean isSelected{get; set;}
        public Boolean isDefault{get; set;}
        public String name {get; set;}
        public Folder__c folder {get; set;}
        public String location {get; set;}
        public BucketInfo( String id, String name, String description, String location, Boolean isSelected, Boolean isDefault){
            folder = new Folder__c(Description__c = description);
            this.isSelected = isSelected;
            this.id = id;
            this.isDefault = isDefault;
            this.name = name;
            this.location = location;
        }
    }
}