public with sharing class BT_ViewSelection_Project {
	@AuraEnabled
    public static List<MasterList> getClientSelections(Id recordId)
    {
        List<buildertek__Selection__c> clientSelections = [SELECT Id, Name, buildertek__Type__c, buildertek__Status__c, buildertek__Project__c FROM buildertek__Selection__c WHERE buildertek__Project__c = :recordId];

        List<Id> categoryIds = new List<Id>();
        for(buildertek__Selection__c sheet : clientSelections)
        {
            categoryIds.add(sheet.Id);
        }
        List<buildertek__Section__c> categoriesSelected = [SELECT Id, Name, buildertek__Selection__c FROM buildertek__Section__c WHERE buildertek__Selection__c IN :categoryIds];

        List<Id> typeIds = new List<Id>();
        for(buildertek__Section__c cat : categoriesSelected)
        {
            typeIds.add(cat.Id);
        }
        List<buildertek__Question_Group__c> typesSelected = [SELECT Id, Name, buildertek__Section__c, buildertek__Temp_Key__c FROM buildertek__Question_Group__c WHERE buildertek__Section__c IN :typeIds];

        List<Id> optionsIds = new List<Id>();
        for(buildertek__Question_Group__c opt : typesSelected)
        {
            optionsIds.add(opt.Id);
        }

        List<buildertek__Question__c> optionsSelected = [SELECT Id, Name, buildertek__Question_Group__c,buildertek__Selected__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c IN :optionsIds];

        List<MasterList>finalOutput = new List<MasterList>();

        for(buildertek__Selection__c sheet: clientSelections)
        {
            List<Types> relatedTypes = new List<Types>();
            List<buildertek__Question__c> relatedOptions = new List<buildertek__Question__c>();
            Id tempId;
            List<Categories> catList = new List<Categories>();

            for(buildertek__Section__c cat: categoriesSelected)
            {
                if(cat.buildertek__Selection__c == sheet.Id)
                {
                    for(buildertek__Question_Group__c catType: typesSelected)
                    {

                    	if(catType.buildertek__Section__c == cat.Id)
                        {
                            for(buildertek__Question__c o : optionsSelected)
                            {
                                if(o.buildertek__Question_Group__c == catType.id)
                                {
                                    System.debug('MATCHED Option:' + o.Name + ', ' + catType.Name);
                                    relatedOptions.add(o);
                                }
                            }

               				List<Options> relatedOptionsList = new List<Options>();
                            for(buildertek__Question__c relopt : relatedOptions)
                            {
                                string icon = '';
                                string iconLbl = '';
                                if(relopt.buildertek__Selected__c == true)
                                {
                                    icon = 'utility:check';
                                    iconLbl = 'Selected Option - ';
                                }
                                Options newOpt = new Options(relopt.Id, relopt.Name, relopt.buildertek__Question_Group__c,icon,iconLbl);
                                relatedOptionsList.add(newOpt);
                            }
                            Types opt = new Types(catType.Id,catType.Name, catType.buildertek__Section__c, relatedOptionsList);
                            relatedTypes.add(opt);
                        }
                    }

                    Categories ca = new Categories(cat.Id, cat.Name, cat.buildertek__Selection__c, relatedTypes);
                	catList.add(ca);
                }
            }
            System.debug(catList);
			finalOutput.add(new MasterList(sheet.Id,sheet.Name,sheet.buildertek__Type__c,sheet.buildertek__Status__c,catList));
        }
        return finalOutput;
    }

    public class MasterList
    {
        @AuraEnabled
        public string selectionid;
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string SelectionType;
        @AuraEnabled
        public string SelectionStatus;
        @AuraEnabled
        public List<Categories> categories;

        public MasterList(string sId, string cSel, string sType, string sStatus, List<Categories> cats)
        {
            this.selectionid = sId;
            this.Id = sId;
            this.Name = cSel;
            this.SelectionType = sType;
            this.SelectionStatus = sStatus;
            this.categories = cats;
            //this.cattypes = catType;
        }
    }
        public class Categories
        {
            @AuraEnabled
        	public string Id;
        	@AuraEnabled
        	public string Name;
        	@AuraEnabled
        	public string selectionid;
        	@AuraEnabled
        	public List<Types> cattypes;

            public Categories(string catId, string catName, string catSID, List<Types> types)
            {
               this.Id = catId;
               this.Name = catName;
               this.selectionid = catSID;
               this.cattypes = types;
            }
        }

        public class Types
        {
            @AuraEnabled
        	public string Id;
        	@AuraEnabled
        	public string Name;
        	@AuraEnabled
        	public string selectionid;
        	@AuraEnabled
        	public List<Options> options;
            @AuraEnabled
            public string iconToUse;
            @AuraEnabled
            public string iconLabelToUse;

            public Types(string optId, string optName, string optSID, List<Options> opts)
            {
               this.Id = optId;
               this.Name = optName;
               this.selectionid = optSID;
               this.options = opts;
               this.iconToUse = 'utility:strategy';
               this.iconLabelToUse = 'Add Options to ';
            }
        }
        public class Options
        {
            @AuraEnabled
        	public string Id;
        	@AuraEnabled
        	public string Name;
            @AuraEnabled
            public string relatedTypeId;
            @AuraEnabled
            public string iconToUse;
            @AuraEnabled
            public string iconLabelToUse;

            public Options(string optId, string optName, string optSID, string icon, string iconLbl)
            {
               this.Id = optId;
               this.Name = optName;
               this.relatedTypeId = optSID;
               this.iconToUse = icon;
               this.iconLabelToUse = iconLbl;
            }
        }
}