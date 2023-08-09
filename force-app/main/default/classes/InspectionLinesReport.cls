public with sharing class InspectionLinesReport{
	public String recId { get; set; }
	public String piechartString { get; set; }
	public InspectionLinesReport(){
		recId = ApexPages.currentPage().getParameters().get('id');
		List<buildertek__Inspection_Line__c> inspectionLines ;
		if (Schema.sObjectType.buildertek__Inspection_Line__c.fields.Id.isAccessible() && 
            Schema.sObjectType.buildertek__Inspection_Line__c.fields.buildertek__Inspection__c.isAccessible() &&
             Schema.sObjectType.buildertek__Inspection_Line__c.fields.Name.isAccessible()) {
	        inspectionLines = [SELECT Id, buildertek__Inspection__c, Name FROM buildertek__Inspection_Line__c WHERE buildertek__Inspection__c =: recId];
        }
	    List<PieData> data = new List<PieData>();
	    Map<String, String> NewMapList = new Map<String, String>();
	    list<buildertek__Inspection_Line__c> inspectionLinesList = new list<buildertek__Inspection_Line__c>();
	    for(buildertek__Inspection_Line__c temp : inspectionLines){ 
	        NewMapList.put(temp.Id, temp.Name);  
	    }
	    List<PieAllData> datas = new List<PieAllData>();
	    List<PieData> dataPie = new List<PieData>();
	    for(String key : NewMapList.keySet())
        {
            dataPie.add(new PieData(NewMapList.get(key), NewMapList.get(key)));
            datas.add(new PieAllData(key,dataPie));
        }
        piechartString = JSON.serialize(datas);
        system.debug('piechartString'+piechartString);
	}

	public class PieData {
		public String name { get; set; }
		public String data { get; set; }
		public PieData(String namevalue, String datavalue) {
			name = namevalue;
			data = datavalue;
		}
	}
	public Class PieAllData{
		public string Values{get;set;}
			public list<PieData> Pielist{get;set;}
			public PieAllData(String Values,list<PieData> Pielist) 
			{  
				this.Values = Values;  
				this.Pielist = Pielist;
			}  
		}
}